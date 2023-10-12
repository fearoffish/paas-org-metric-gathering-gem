# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class Services
      def self.first(name:)
        # Find the broker, then find all offerings for that broker, then all plans
        # { broker: { offerings: { plans: [] } }
        # e.g. { "p-mysql (guid)": { "10mb (guid)": [], "100mb (guid)": [] } }
        broker = ServiceBroker.first(name: name)
        offerings = ServiceOffering.all(service_broker_guids: broker.guid).map do |offering|
          plans = ServicePlan.all(service_offering_guids: offering.guid)
          { offering.to_s => plans }
        end
        { broker.to_s => offerings }
      end
    end
  end
end
