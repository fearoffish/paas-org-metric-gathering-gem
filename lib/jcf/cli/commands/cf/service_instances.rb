# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServiceInstances < Command
          argument :name, required: false, desc: "Service Instance name"

          option :org, aliases: ["-o", "--org", "--organization"], type: :string, desc: "Filter to an organization guid"
          option :space, aliases: ["-s", "--space"], type: :string, desc: "Filter to a space guid"
          option :service_plan, aliases: ["-p", "--plan", "--service-plan"], type: :string,
                                desc: "Filter to a service plan"

          def call(name: nil, **options)
            if name
              out.puts formatter.format(JCF::CF::ServiceInstance.find_by(name: name))
            else
              out.puts formatter.format(
                JCF::CF::ServiceInstance.all(
                  organization_guids: options[:org],
                  space_guids: options[:space],
                  service_plan: options[:service_plan]
                )
              )
            end
          end
        end
      end
    end
  end
end
