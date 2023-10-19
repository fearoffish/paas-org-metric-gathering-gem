# frozen_string_literal: true

require "json"

module JCF
  module CLI
    module OutputFormatters
      class JSON
        def self.format(data:)
          return "{}" if data.nil? || data.empty?

          array = data.values.first.length.times.map do |i|
            data.each_with_object({}) do |(key, values), acc|
              acc[key] = values[i]
            end
          end
          array.to_json
        end
      end
    end
  end
end
