# frozen_string_literal: true

require "tty-table"

module JCF
  module CLI
    module OutputFormatters
      class Text
        class << self
          # @param data [Hash] the data to be formatted
          # @param tree [Boolean] whether to format as a tree or a table
          # @return [String] the formatted data
          # @example
          #
          # data: { header1: %w[name1 name2], header2: %w[space1 space2]}
          # output:
          # ┌────────┬────────┐
          # │header1 │header2 │
          # ├────────┼────────┤
          # │name1   │space1  │
          # │name2   │space2  │
          # └────────┴────────┘
          def format(data:, tree: false)
            return "" if data.nil? || data.empty?

            if tree
              render_tree(data)
            else
              render_data(data)
            end
          end

          private

          # @param data [Hash] the data to be formatted
          # @return [String] the formatted data
          # @example
          #
          # data: { header1: %w[name1 name2], header2: %w[space1 space2]}
          # values: [["name1", "space1"], ["name2", "space2"]]
          def render_data(data)
            keys = data.keys.collect(&:to_s)
            values = data.values.transpose

            table = TTY::Table.new(keys, values)
            table.render(:unicode, resize: true)
          end

          def render_tree(data)
            TTY::Tree.new(data).render
          end
        end
      end
    end
  end
end
