# frozen_string_literal: true

require "yaml"

module JCF
  module CLI
    module Helpers
      def stub_curl(resource)
        allow(JCF::CF)
          .to receive(:curl)
          .and_return(fixture(resource))
      end

      def fixture(name)
        jsonify(File.read(File.join(__dir__, "fixtures", "#{name}.json")))
      end

      def jsonify(json)
        JSON.parse(json).deep_symbolize_keys
      end

      def test_guid(resource, number = 0)
        "test-#{resource.name.demodulize.underscore.dasherize}-#{number}-guid"
      end

      def test_name(resource, number = 0)
        "test-#{resource.name.demodulize.underscore.dasherize}-#{number}-name"
      end

      def test_object(name, klass)
        json = fixture(name)
        klass.new(
          name: json[:name],
          guid: json[:guid],
          relationships: json[:relationships]
        )
      end
    end
  end
end
