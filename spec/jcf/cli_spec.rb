# frozen_string_literal: true

RSpec.describe JCF::CLI do
  describe ".template_parser" do
    it "returns the same string given no options" do
      expect(described_class.template_parser("rdsbroker", nil)).to eq("rdsbroker")
    end

    it "replaces a single token" do
      expect(described_class.template_parser("rdsbroker-{guid}", "guid=1234")).to eq("rdsbroker-1234")
    end

    it "replaces multiple tokens" do
      expect(
        described_class.template_parser(
          "rdsbroker-{guid}-{name}", "guid=1234,name=test"
        )
      ).to eq("rdsbroker-1234-test")
    end
  end
end
