# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServiceBrokers < Command
          argument :name, required: false, desc: "Service Broker name"

          option :space, aliases: ["-s", "--space"], type: :string, desc: "Filter to a space"

          def call(name: nil, **options)
            if name
              out.puts formatter.format(JCF::CF::ServiceBroker.find_by(name: name))
            else
              out.puts formatter.format(
                JCF::CF::ServiceBroker.all(
                  space_guids: options[:space]
                )
              )
            end
          end
        end
      end
    end
  end
end
