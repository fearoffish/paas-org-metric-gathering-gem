# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class Organizations < Command
          argument :name, required: false, desc: "Organization name"

          def call(name: nil, **)
            if name
              out.puts formatter.format(JCF::CF::Organization.find_by(name: name))
            else
              out.puts formatter.format(JCF::CF::Organization.all)
            end
          end
        end
      end
    end
  end
end
