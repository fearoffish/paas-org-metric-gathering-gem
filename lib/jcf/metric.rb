# frozen_string_literal: true

require_relative "base"

module JCF
  class Metric
    attr_accessor :name, :value

    def to_s
      "#{name}: #{value}"
    end
  end
end
