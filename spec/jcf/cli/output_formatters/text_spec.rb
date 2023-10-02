# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::Text do
  describe ".format" do
    let(:org) { JCF::CF::Organization.new(name: "foo", guid: "bar") }
    let(:org2) { JCF::CF::Organization.new(name: "moo", guid: "rar") }

    it "returns an empty string when given nil" do
      expect(described_class.format(nil)).to eq("")
    end

    it "returns all entries" do
      %w[foo bar moo rar].each do |keyword|
        expect(described_class.format([org, org2])).to include(keyword)
      end
    end

    it "returns the correct number of lines" do
      expect(described_class.format([org, org2])).to include("\n").exactly(5).times
    end

    it "returns a corner graphic" do
      expect(described_class.format([org, org2])).to include("┌─")
    end

    it "returns a border graphic" do
      expect(described_class.format([org, org2])).to include("│")
    end

    it "returns a single line for a single entry" do
      %w[foo bar].each do |keyword|
        expect(described_class.format([org])).to include(keyword)
      end
    end
  end
end
