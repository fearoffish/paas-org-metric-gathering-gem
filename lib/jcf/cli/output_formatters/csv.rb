# frozen_string_literal: true

require "csv"

module JCF
  module CLI
    module OutputFormatters
      class CSV
        class << self
          def format(data)
            case data
            in Array
              array = data.collect(&:serializable_hash)
              generate_csv(headers: array.first&.keys, values: array)
            in Hash
              generate_csv(headers: data.keys.sort, values: [data.serializable_hash])
            else
              generate_csv(headers: [], values: [])
            end
          end

          private

          def generate_csv(headers:, values:)
            ::CSV.generate(headers: headers, write_headers: true) do |csv|
              values.each do |hash|
                csv << hash.values
              end
            end
          end
        end
      end
    end
  end
end
