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
            data = if name
                     JCF::CF::User.all(partial_usernames: name)
                   else
                     JCF::CF::User.all
                   end

            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end
        end
      end
    end
  end
end
