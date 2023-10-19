# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class Quota < Command
          argument :name, required: false, desc: "Quota name"

          option :org, aliases: ["-o", "--org", "--organization"], type: :string, desc: "Filter to an organization"

          def call(name: nil, **options)
            data = if name
                     JCF::CF::Quota.find_by(name: name)
                   else
                     JCF::CF::Quota.all(org: options[:org])
                   end
            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end
        end
      end
    end
  end
end
