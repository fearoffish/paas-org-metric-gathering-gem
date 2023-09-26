# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class Metric < Base
      attr_accessor :name
      attr_accessor :region
      attr_accessor :organization
      attr_accessor :organization_guid
      attr_accessor :space
      attr_accessor :space_guid
      attr_accessor :service_broker_name
      attr_accessor :service_broker_guid
      attr_accessor :service_offering
      attr_accessor :service_plan
      attr_accessor :storage_allocated, :storage_used, :storage_free
      attr_accessor :iops
      attr_accessor :cpu

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

      def to_s
        "#{name}: used(#{storage_used}) allocated(#{storage_allocated}) free(#{storage_free}) iops(#{iops}) cpu(#{cpu})"
      end
    end
  end
end
