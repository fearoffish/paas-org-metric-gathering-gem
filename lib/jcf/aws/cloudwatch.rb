# frozen_string_literal: true

require "aws-sdk-cloudwatch"
require "aws-sdk-rds"
require "active_support/core_ext/integer/time"
require "active_support/isolated_execution_state"
require "filesize"

module JCF
  module AWS
    class CloudWatch
      NAMESPACES = {
        rds: "AWS/RDS",
        s3: "AWS/S3"
      }
      METRICS = {
        free_storage: "FreeStorageSpace",
        allocated_storage: "AllocatedStorage",
        iops: "WriteIOPS",
        cpu: "CPUUtilization"
      }

      def storage_free(guid:)
        storage_free = rds(guid: guid, metric: :free_storage)
        storage_free.to_i
      end

      def storage_allocated(guid:)
        rds = Aws::RDS::Client.new
        size = rds
               .describe_db_instances(db_instance_identifier: rds_guid(guid))
               .db_instances.first.allocated_storage
        Filesize.from("#{size} GB").to_i
      end

      def storage_used(guid:)
        free = storage_free(guid: guid)
        allocated = storage_allocated(guid: guid)
        allocated - free
      end

      def iops(guid:)
        iops = rds(guid: guid, metric: :iops)
      end

      def cpu(guid:)
        cpu = rds(guid: guid, metric: :cpu)
      end

      private

      def rds(guid:, metric:)
        dimensions = { name: "DBInstanceIdentifier", value: rds_guid(guid) }
        aws(guid: guid, namespace: NAMESPACES[:rds], metric: METRICS[metric], dimensions: dimensions)
      end

      def s3(bucket:, metric:)
        dimensions = [
          { name: "BucketName", value: bucket },
          { name: "StorageType", value: "StandardStorage" }
        ]
        aws(guid: guid, namespace: NAMESPACES[:s3], metric: METRICS[metric], dimensions: dimensions)
      end

      def aws(guid:, namespace:, metric:, dimensions:, start_time: nil, end_time: nil, period: nil, statistic: nil)
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
      rescue Aws::Errors::MissingCredentialsError => e
        puts "You are not logged in to an AWS shell.  'gds aws <ACCOUNT> -s'"
      end

      def rds_guid(guid)
        "rdsbroker-#{guid}"
      end
    end
  end
end
