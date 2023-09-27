# frozen_string_literal: true

require "csv"

module JCF
  module CLI
    module OutputFormatters
      class CSV
        def self.format(data)
          if data.is_a?(Enumerable)
            array = data.collect(&:serializable_hash)
            ::CSV.generate(headers: array.first&.keys, write_headers: true) do |csv|
              array.each do |hash|
                csv << hash.values
              end
            end
          else
            hash = data.serializable_hash
            ::CSV.generate(headers: data.keys.sort, write_headers: true) do |csv|
              csv << hash.values
            end
          end
        end
      end
    end
  end
end
