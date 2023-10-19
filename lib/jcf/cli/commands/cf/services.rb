# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"
require "tty-tree"

module JCF
  module CLI
    module Commands
      module CF
        class Services < Command
          argument :broker, required: true, desc: "Broker name"

          def call(broker:, **)
            # gather all service offerings and plans for a single broker
            out.puts formatter.format(data: JCF::CF::Services.first(name: broker), tree: true)
          end
        end
      end
    end
  end
end
