# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServiceBrokers < Command
          include JCF::CF

          argument :name, required: false, desc: "Service Broker name"

          option :space, aliases: ["-s", "--space"], type: :string, desc: "Filter to a space"

          def call(name: nil, **options)
            if name
              out.puts formatter.format(data: JCF::CF::ServiceBroker.find_by(name: name))
            else
              # [
              #   #<ServiceBroker @name="cdn-broker", @guid="aaaa", @relationships=[]>,
              #   #<ServiceBroker @name="rds-broker", @guid="bbbb", @relationships=[]>
              # ]
              # output = { name: %w[cdn-broker rds-broker], header2: %w[aaaa bbbb]}

              data = ServiceBroker.all(space_guids: options[:space])

              out.puts formatter.format(data: JCF::CF::Base.format(data))
            end
          end
        end
      end
    end
  end
end
