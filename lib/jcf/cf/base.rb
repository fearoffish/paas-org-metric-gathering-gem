# frozen_string_literal: true

require "json"
require "English"
require "active_model"
require "active_model/serializers/json"
require "active_support/core_ext/hash"
require "active_support/core_ext/string"
require "active_support/core_ext/object"

module JCF
  module CF
    class Base
      include ActiveModel::Model
      include ActiveModel::Serialization
      include ActiveModel::Validations

      attr_accessor :name, :guid, :relationships, :raw

      validates_presence_of :name, :guid

      def attributes
        { name: name, guid: guid, relationships: relationships }
      end

      def keys
        attributes.keys
      end

      def values
        attributes.values
      end

      def initialize(name: nil, guid: nil, relationships: nil)
        @name = name
        @guid = guid
        @relationships = Relationships.new(self, relationships)
      end

      class << self
        attr_accessor :endpoint

        def keys = new.keys

        def find_by(attrs)
          objects = all
          objects.find_all do |obj|
            keys = obj.attributes.keys & attrs.keys
            keys.all? do |key|
              return true if attrs[key].nil?

              obj.attributes[key].include? attrs[key]
            end
          end
        end

        def first(attrs)
          find_by(attrs).first
        end

        def find(guid)
          new(guid: guid).populate!
        end

        # TODO: make this less greedy
        def all(params = {})
          params.compact!

          resources(params: params)
        end

        def resource_url
          endpoint || name.demodulize.tableize
        end

        def format(data)
          data.each_with_object({}) do |broker, h|
            broker.attributes.each do |k, v|
              h[k] ||= []
              h[k] << v
            end
          end
        end

        private

        def resources(params: {})
          params.compact!

          hash = JCF::CF.curl(resource_url, params: params)
          populate_objects(hash)
        end

        def populate_objects(hash)
          hash[:resources].map! do |object|
            o = new(
              guid: object[:guid],
              name: object[:name],
              relationships: object[:relationships]
            )
            o
          end
        end
      end

      def to_s
        "#{name} #{guid}"
      end

      def populate!
        resource(guid)
      end

      private

      def resource(guid)
        object = self.class.all.find { |obj| obj.guid == guid }
        return object if object

        hash = JCF::CF.curl("#{self.class.resource_url}/#{guid}", params: nil)
        parse_object(hash)
      end

      def parse_object(hash)
        hash[:resources].first if hash[:resources].is_a?(Array)

        hash[:guid]
        hash[:name]
        (hash[:relationships] || {})
        self
      end
    end
  end
end
