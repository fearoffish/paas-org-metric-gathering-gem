# frozen_string_literal: true

require "json"

module JCF
  module CLI
    module OutputFormatters
      class JSON
        def self.format(data)
          if data.is_a?(Enumerable)
            ::JSON.generate data.collect(&:serializable_hash)
          else
            ::JSON.generate data.serializable_hash
          end
        end
      end
    end
  end
end
