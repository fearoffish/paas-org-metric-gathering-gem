# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::JSON do
  describe ".format" do
    it "returns an empty JSON string" do
      expect(described_class.format({})).to eq("[]")
    end

    it "returns a valid JSON string" do
      json = JSON.parse(
        described_class.format(JCF::CF::Organization.new(name: "foo", guid: "bar"))
      )

      expect(json).to eq({ "name" => "foo", "guid" => "bar", "relationships" => "" })
    end
  end
end
