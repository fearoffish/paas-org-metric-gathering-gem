# frozen_string_literal: true

require "shellwords"
require_relative "../../errors"

module JCF
  module CLI
    module Commands
      module CF
        class Spaces < Command
          argument :name, required: false, desc: "Space name"

          option :org, aliases: ["-o", "--org", "--organization"], type: :string, desc: "Filter to an organization"

          def call(name: nil, **options)
            data = if name
                     JCF::CF::Space.find_by(name: name)
                   else
                     JCF::CF::Space.all(organization_guids: options[:org])
                   end

            out.puts formatter.format(data: JCF::CF::Base.format(data))
          end
        end
      end
    end
  end
end
