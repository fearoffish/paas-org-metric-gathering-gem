# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class Relationships
      include Enumerable

      attr_reader :belongs_to

      def initialize(belongs_to, relationships = {})
        relationships = {} if relationships.nil?
        raise ArgumentError, "expects a hash" unless relationships.is_a?(Hash)

        @belongs_to = belongs_to
        @relationships = convert_to_classes(relationships)
      end

      def each(&block)
        @relationships&.each(&block)
      end

      def inspect
        @relationships.inspect
      end

      def relationship?(method_name)
        klass = get_klass(method_name)

        matches = @relationships.filter_map do |relationship|
          relationship.instance_of?(klass) ? relationship : nil
        end.compact

        matches.any?
      rescue NameError
        false
      end

      def respond_to_missing?(method_name, include_private = false)
        relationship?(method_name) || super
      end

      def method_missing(method_name, *args, &block)
        if relationship?(method_name)
          klass = get_klass(method_name)

          matches = @relationships.filter_map do |relationship|
            relationship.instance_of?(klass) ? relationship : nil
          end

          matches.size == 1 ? matches.first : matches
        else
          super
        end
      end

      def to_s
        @relationships.collect do |relationship|
          "#{relationship.class.name.demodulize}: #{relationship.name || ""} (#{relationship.guid})"
        end.join(", ")
      end

      private

      def convert_to_classes(relationships = {})
        return {} if relationships.nil?

        relationships.collect do |relationship_type, data_hash|
          klass = get_klass(relationship_type)
          data = make_array(data_hash[:data])

          data.collect do |d|
            klass.new(guid: (d || {})[:guid])
          end.flatten
        end.flatten
      end

      def get_klass(method)
        "JCF::CF::#{method.to_s.singularize.camelize}".constantize
      end

      def make_array(data)
        data.is_a?(Array) ? data : [data]
      end
    end
  end
end
