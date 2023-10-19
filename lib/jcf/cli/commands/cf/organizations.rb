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
            data = if name
                     Organization.find_by(name: name)
                   else
                     Organization.all
                   end
            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end
        end
      end
    end
  end
end
