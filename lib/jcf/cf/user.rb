# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class User < Base
      attr_accessor :username, :guid, :presentation_name, :raw

      validates_presence_of :username, :guid, :presentation_name

      def attributes
        { username: username, guid: guid, presentation_name: presentation_name }
      end

      def initialize(username: nil, guid: nil, presentation_name: nil)
        @name = name
        @guid = guid
        @presentation_name = presentation_name
      end

      def self.populate_objects(hash)
        hash[:resources].map! do |object|
          o = new(
            guid: object[:guid],
            username: object[:username],
            presentation_name: object[:presentation_name]
          )
          o
        end
      rescue NoMethodError
        puts "object is #{hash[:resources]}"
      end
    end
  end
end
