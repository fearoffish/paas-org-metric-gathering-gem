# frozen_string_literal: true

require "aws-sdk-cloudwatch"
require "aws-sdk-rds"
require "active_support/core_ext/integer/time"
require "active_support/isolated_execution_state"
require "filesize"

module JCF
  module Plugins
    class AwsRds
      def initialize(name:)
        @name = name
        @metrics = {}
        check_token!
      end

      def names
        %w[storage_used storage_allocated storage_free iops cpu]
      end

      def values
        names.map { |name| send(name.to_sym) }
      end

      def metrics
        @metrics[:storage_used] = to_gb(storage_used(name: @name || ""))
        @metrics[:storage_allocated] = to_gb(storage_allocated(name: @name) || "")
        @metrics[:storage_free] = to_gb(storage_free(name: @name) || "")
        @metrics[:iops] = (iops(name: @name).to_fs(:rounded, precision: 0) || "")
        @metrics[:cpu] = (cpu(name: @name).to_fs(:rounded, precision: 0) || "")
        @metrics
      end

      def to_s
       metrics.to_s
      end

      private

      def check_token!
        Aws::STS::Client.new.get_caller_identity({})
      rescue Aws::Errors::MissingCredentialsError
        raise JCF::CLI::NotLoggedInError, "Your AWS token has expired.  Please log in again."
      end

      METRICS = {
        free_storage: "FreeStorageSpace",
        allocated_storage: "AllocatedStorage",
        iops: "WriteIOPS",
        cpu: "CPUUtilization"
      }.freeze

      def storage_free(name:)
        storage_free = cloudwatch(name: name, metric: "FreeStorageSpace")
        storage_free.to_i
      end

      def storage_allocated(name:)
        rds = Aws::RDS::Client.new
        size = rds
                .describe_db_instances(db_instance_identifier: name)
                .db_instances.first.allocated_storage
        Filesize.from("#{size} GB").to_i
      end

      def storage_used(name:)
        free = storage_free(name: name)
        allocated = storage_allocated(name: name)
        allocated - free
      end

      def iops(name:)
        cloudwatch(name: name, metric: :iops)
      end

      def cpu(name:)
        cloudwatch(name: name, metric: :cpu)
      end

      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def cloudwatch(name:, metric:)
        cloudwatch = Aws::CloudWatch::Client.new
        res = cloudwatch.get_metric_statistics({
          namespace: "AWS/RDS",
          metric_name: metric,
          dimensions: [{ name: "DBInstanceIdentifier", value: name }],
          start_time: 1.day.ago,
          end_time: Time.now,
          period: 86_400,
          statistics: ["Average"]
        })

        pp res if ENV["DEBUG"]

        res.datapoints.first&.average || 0
      rescue Aws::Errors::MissingCredentialsError
        puts "You are not logged in to an AWS shell.  'gds aws <ACCOUNT> -s'"
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def to_gb(bytes)
        Filesize.from("#{bytes} b").to("GB").to_fs(:rounded, precision: 2)
      rescue ArgumentError
        0
      end
    end

    register_plugin :aws_rds, AwsRds
  end
end
