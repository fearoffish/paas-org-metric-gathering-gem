# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServicePlans < Command
          argument :name, required: false, desc: "Service Plan name"

          option :org, aliases: ["-O", "--org", "--organization"], type: :string, desc: "Filter to an organization guid"
          option :service_offering, aliases: ["-o", "--offering", "--service-offering"], type: :string,
                                desc: "Filter to a service offering name"
          option :service_broker, aliases: ["-b", "--broker", "--service-broker"], type: :string,
                                desc: "Filter to a service broker name"

          def call(name: nil, **options)
            data = if name
                     JCF::CF::ServicePlan.find_by(name: name)
                   else
                     JCF::CF::ServicePlan.all(
                       organization_guids: options[:org],
                       service_offering_names: options[:service_offering],
                       service_broker_names: options[:service_broker]
                     )
                   end

            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end
        end
      end
    end
  end
end
