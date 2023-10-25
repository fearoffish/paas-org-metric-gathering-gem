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

          option :instances, type: :boolean, desc: "Show instances for each service (this is an API heavy call)"

          def call(broker:, **options)
            # gather all service offerings and plans for a single broker
            out.puts formatter.format(data: JCF::CF::Services.first(name: broker, instances: options[:instances]), tree: true)
          end
        end
      end
    end
  end
end
