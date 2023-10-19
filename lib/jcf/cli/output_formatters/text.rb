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
            keys = collect_keys(data)
            values = collect_values(data)

            table = TTY::Table.new(keys, values)
            table.render(:unicode, resize: true)
          end

          def render_tree(data)
            TTY::Tree.new(data).render
          end

          def collect_keys(data)
            return ["Empty result"] if !data || data.empty?

            if data.is_a?(Array)
              data.first.keys.collect(&:to_s)
            elsif data.is_a?(Hash)
              data.keys.collect(&:to_s) || ["Empty result"]
            else
              data.keys.collect(&:to_s)
            end
          end

          # Hash:
          #   values: [["name1", "name2"], ["space1", "space2"]]
          #   output: [["name1", "space1"], ["name2", "space2"]]
          def collect_values(data)
            return [["Empty result"]] if !data || data.empty?

            if data.is_a?(Array)
              data.map { |d| d.attributes.values.collect(&:to_s) }
            elsif data.is_a?(Hash)
              data.values.transpose
            else
              [data.attributes.values.collect(&:to_s)]
            end
          end
        end
      end
    end
  end
end
