# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServiceInstances < Command
          argument :name, required: false, desc: "Service Instance name"

          option :org, aliases: ["-O", "--org", "--organization"], type: :string, desc: "Filter to an organization guid"
          option :space, aliases: ["-S", "--space"], type: :string, desc: "Filter to a space guid"
          option :service_plan, aliases: ["-p", "--plan", "--service-plan"], type: :string,
                                desc: "Filter to a service plan name"

          def call(name: nil, **options)
            data = if name
                     JCF::CF::ServiceInstance.find_by(name: name)
                   else
                     JCF::CF::ServiceInstance.all(
                       organization_guids: options[:org],
                       space_guids: space_guids_lookup(options[:space]),
                       service_plan_names: options[:service_plan]
                     )
                   end

            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end

          private

          def space_guids_lookup(option)
            return nil if option.nil?

            JCF::CF::Space.find_by(name: option).map(&:guid)
          end
        end
      end
    end
  end
end
