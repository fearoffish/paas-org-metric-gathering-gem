# frozen_string_literal: true

require "aws-sdk-cloudwatch"
require "aws-sdk-elasticache"
require "active_support/core_ext/integer/time"
require "active_support/isolated_execution_state"
require "filesize"

module JCF
  module Plugins
    class AwsElastiCache
      def initialize(name:)
        @name = name
        @metrics = {}
        check_token!
      end

      def names
        %w[cpu used_storage]
      end

      def values
        names.map { |name| send(name.to_sym) }
      end

      def metrics
        @metrics[:cpu] = (cpu(name: @name).to_fs(:rounded, precision: 0) || "")
        @metrics[:used_storage] = to_gb(storage_used(name: @name || ""))
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
        used_storage: "BytesUsedForCache",
        cpu: "CPUUtilization"
      }.freeze

      def used_storage(name:)
        cloudwatch(name: name, metric: :used_storage)
        Filesize.from("#{size} GB").to_i
      end

      def cpu(name:)
        cloudwatch(name: name, metric: :cpu)
      end

      # rubocop:disable Metrics/MethodLength
      def cloudwatch(name:, metric:)
        cloudwatch = Aws::CloudWatch::Client.new
        res = cloudwatch.get_metric_statistics({
                                                 namespace: "AWS/ElastiCache",
                                                 metric_name: metric,
                                                 dimensions: [
                                                   { name: "CacheClusterId", value: name },
                                                   { name: "CacheNodeId", value: "0001" }
                                                 ],
                                                 start_time: 1.day.ago,
                                                 end_time: Time.now,
                                                 period: 86_400,
                                                 statistics: ["Average"]
                                               })

        pp res if ENV["DEBUG"]

        res.datapoints.first&.average || 0
      rescue Aws::Errors::MissingCredentialsError
        $stderr.puts "You are not logged in to an AWS shell.  'gds aws <ACCOUNT> -s'"
      end
      # rubocop:enable Metrics/MethodLength

      def to_gb(bytes)
        Filesize.from("#{bytes} b").to("GB").to_fs(:rounded, precision: 2)
      rescue ArgumentError
        0
      end
    end

    register_plugin :aws_elasticache, AwsElastiCache
  end
end
