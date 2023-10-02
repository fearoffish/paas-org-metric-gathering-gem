# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class ServiceOfferings < Command
          argument :name, required: false, desc: "Service Offering name"

          def call(name: nil, **_options)
            if name
              out.puts formatter.format(JCF::CF::ServiceOffering.find_by(name: name))
            else
              out.puts formatter.format(JCF::CF::ServiceOffering.all)
            end
          end
        end
      end
    end
  end
end
