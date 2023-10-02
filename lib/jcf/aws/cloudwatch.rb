# frozen_string_literal: true

require "aws-sdk-cloudwatch"
require "aws-sdk-rds"
require "aws-sdk-s3"
require "active_support/core_ext/integer/time"
require "active_support/isolated_execution_state"
require "filesize"

module JCF
  module AWS
    class CloudWatch
      NAMESPACES = {
        rds: "AWS/RDS",
        s3: "AWS/S3"
      }.freeze
      METRICS = {
        free_storage: "FreeStorageSpace",
        allocated_storage: "AllocatedStorage",
        iops: "WriteIOPS",
        cpu: "CPUUtilization"
      }.freeze

      def storage_free(name:)
        storage_free = rds(name: name, metric: :free_storage)
        storage_free.to_i
      end

      def storage_allocated(name:)
        rds = Aws::RDS::Client.new
        size = rds
               .describe_db_instances(db_instance_identifier: name)
               .db_instances.first.allocated_storage
        Filesize.from("#{size} GB").to_i
      end

      def rds_storage_used(name:)
        free = storage_free(name: name)
        allocated = storage_allocated(name: name)
        allocated - free
      end

      def s3_storage_used(name:)
        s3 = Aws::S3::Client.new
        total_size = 0
        response = s3.list_objects_v2(bucket: name)
        response.contents.each do |object|
          total_size += object.size
        end
        total_size
      end

      def iops(name:)
        rds(name: name, metric: :iops)
      end

      def cpu(name:)
        rds(name: name, metric: :cpu)
      end

      private

      def rds(name:, metric:)
        dimensions = { name: "DBInstanceIdentifier", value: name }
        aws(namespace: NAMESPACES[:rds], metric: METRICS[metric], dimensions: dimensions)
      end

      # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def aws(namespace:, metric:, dimensions:, start_time: nil, end_time: nil, period: nil, statistic: nil)
        cloudwatch = Aws::CloudWatch::Client.new
        res = cloudwatch.get_metric_statistics({
                                                 namespace: namespace,
                                                 metric_name: metric,
                                                 dimensions: [dimensions],
                                                 start_time: (start_time || 1.day.ago),
                                                 end_time: (end_time || Time.now),
                                                 period: (period || 86_400),
                                                 statistics: [(statistic || "Average")]
                                               })

        pp res if ENV["DEBUG"]

        res.datapoints.first&.average || 0
      rescue Aws::Errors::MissingCredentialsError
        puts "You are not logged in to an AWS shell.  'gds aws <ACCOUNT> -s'"
      end
      # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
