# frozen_string_literal: true

require "csv"

module JCF
  module CLI
    module OutputFormatters
      class CSV
        class << self
          def format(data:)
            return "" if data.nil? || data.empty?

            ::CSV.generate(headers: data.keys, write_headers: true) do |csv|
              data.values.transpose.each do |value|
                csv << value
              end
            end
          end
        end
      end
    end
  end
end
