# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"
require "tty-tree"

module JCF
  module CLI
    module Commands
      module CF
        class Services < Command
          argument :broker, required: false, desc: "Broker name"

          def call(broker: nil, **)
            # gather all service offerings and plans for a single broker
            if broker
              out.puts formatter.format(JCF::CF::Services.first(name: broker), tree: true)
            else
              # TODO: this is a stub, it should be a list of all brokers
              # out.puts formatter.format(JCF::CF::Organization.all)
            end
          end
        end
      end
    end
  end
end
