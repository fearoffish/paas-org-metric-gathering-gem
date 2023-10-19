# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class Organizations < Command
          include JCF::CF

          argument :name, required: false, desc: "Organization name"

          def call(name: nil, **)
            values = if name
              Organization.find_by(name: name).collect(&:values)
            else
              Organization.all.collect(&:values)
            end
            out.puts formatter.format(headers: Organization.keys, values: values)
          end
        end
      end
    end
  end
end
