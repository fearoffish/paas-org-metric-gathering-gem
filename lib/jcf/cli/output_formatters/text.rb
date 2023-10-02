# frozen_string_literal: true

require "tty-table"

module JCF
  module CLI
    module OutputFormatters
      class Text
        class << self
          def format(data)
            return "" if data.nil?

            keys = collect_keys(data)
            values = collect_values(data)

            table = TTY::Table.new(keys, values)
            table.render(:unicode, resize: true)
          end

          def collect_values(data)
            if data.is_a?(Array)
              data.map { |d| d.attributes.values.collect(&:to_s) }
            else
              [data.attributes.values.collect(&:to_s)]
            end
          end

          def collect_keys(data)
            if data.is_a?(Array)
              data.first&.attributes&.keys || ["Empty result"]
            else
              data.attributes.keys
            end
          end
        end
      end
    end
  end
end
