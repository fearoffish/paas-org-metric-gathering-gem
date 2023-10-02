# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class Metric < Base
      attr_accessor :name, :region, :deploy_env, :organization, :organization_guid, :space, :space_guid,
                    :service_broker_name, :service_broker_guid, :service_offering, :service_plan,
                    :storage_allocated, :storage_used, :storage_free, :iops, :cpu

      # rubocop:disable Metrics/MethodLength
      def attributes
        {
          name: name,
          region: region,
          organization: organization,
          organization_guid: organization_guid,
          space: space,
          space_guid: space_guid,
          service_broker_name: service_broker_name,
          service_broker_guid: service_broker_guid,
          service_offering: service_offering,
          service_plan: service_plan,
          storage_used: storage_used,
          storage_allocated: storage_allocated,
          storage_free: storage_free,
          iops: iops,
          cpu: cpu
        }
      end
      # rubocop:enable Metrics/MethodLength

      def to_s
        "#{name}: used(#{storage_used}) allocated(#{storage_allocated}) free(#{storage_free}) iops(#{iops}) cpu(#{cpu})"
      end
    end
  end
end
