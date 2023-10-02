# frozen_string_literal: true

RSpec.describe JCF::CF::Space do
  include_examples "basic"

  context "with relationships" do
    subject(:with_org) do
      json = fixture("space")
      described_class.new(
        name: json[:name],
        guid: json[:guid],
        relationships: json[:relationships]
      )
    end

    before { stub_curl(klass_plural) }

    it "has an organization" do
      expect(with_org.relationships.organization).to be_a(JCF::CF::Organization)
    end
  end
end
