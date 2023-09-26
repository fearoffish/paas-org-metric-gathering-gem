# frozen_string_literal: true

RSpec.describe JCF::CF::Space do
  include_examples "basic"

  context "relationships" do
    before { stub_curl(klass_plural) }
    subject do
      json = fixture("space")
      described_class.new(
        name: json[:name],
        guid: json[:guid],
        relationships: json[:relationships]
      )
    end

    it "has an organization" do
      expect(subject.relationships.organization).to be_a(JCF::CF::Organization)
    end
  end
end
