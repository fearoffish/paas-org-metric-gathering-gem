# frozen_string_literal: true

require "tty-table"

module JCF
  module CLI
    module OutputFormatters
      class Text
        # data should be a hash with keys for columns and values for rows
        def self.format(data)
          return "" if data.nil?

          keys = []
          values = []
          if data.is_a?(Array)
            keys = data.first.attributes.keys
            values = data.map { |d| d.attributes.values.collect(&:to_s) }
          else
            keys = data.attributes.keys
            values = [data.attributes.values.collect(&:to_s)]
          end

          table = TTY::Table.new(keys, values)
          table.render(:unicode)
        end
      end
    end
  end
end
