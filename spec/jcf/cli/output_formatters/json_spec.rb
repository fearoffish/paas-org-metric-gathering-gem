# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::JSON do
  describe ".format" do
    let(:data) { { header1: ["name1", "name2"], header2: ["space1", "space2"] } }
    subject(:text) { described_class.format(data: data) }

    it "returns an empty JSON string when given nil" do
      expect(described_class.format(data: {})).to eq("{}")
    end

    it "returns a valid JSON string when given valid data" do
      json = JSON.parse(text)

      expect(json).to eq({ "header1" => ["name1", "name2"], "header2" => ["space1", "space2"] })
    end
  end
end
