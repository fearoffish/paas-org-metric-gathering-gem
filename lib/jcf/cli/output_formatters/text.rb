# frozen_string_literal: true

require "tty-table"

module JCF
  module CLI
    module OutputFormatters
      class Text
        class << self
          def format(data:, tree: false)
            return "" if data.nil? || data.empty?

            if tree
              render_tree(data)
            else
              render_data(data)
            end
          end

          private

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
