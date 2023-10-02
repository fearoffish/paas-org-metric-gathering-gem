# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class Users < Command
          argument :name, required: false, desc: "Partial username"

          def call(name: nil, **_options)
            if name
              out.puts formatter.format(JCF::CF::User.all(partial_usernames: name))
            else
              out.puts formatter.format(JCF::CF::User.all)
            end
          end
        end
      end
    end
  end
end
