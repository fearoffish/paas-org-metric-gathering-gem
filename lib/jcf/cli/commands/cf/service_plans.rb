# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServicePlans < Command
          argument :name, required: false, desc: "Service Plan name"

          option :org, aliases: ["-o", "--org", "--organization"], type: :string, desc: "Filter to an organization"

          def call(name: nil, **options)
            if name
              out.puts formatter.format(JCF::CF::ServicePlan.find_by(name: name))
            else
              out.puts formatter.format(
                JCF::CF::ServicePlan.all(
                  organization_guids: options[:org]
                )
              )
            end
          end
        end
      end
    end
  end
end
