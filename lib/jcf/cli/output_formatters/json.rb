# frozen_string_literal: true

require "json"

module JCF
  module CLI
    module OutputFormatters
      class JSON
        def self.format(data:)
          return "{}" if data.nil? || data.empty?

          data.to_json
        end
      end
    end
  end
end
