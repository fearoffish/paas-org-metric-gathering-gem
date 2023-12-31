# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::JSON do
  describe ".format" do
    subject(:text) { described_class.format(data: data) }

    let(:data) { { header1: %w[name1 name2], header2: %w[space1 space2] } }

    it "returns an empty JSON string when given nil" do
      expect(described_class.format(data: {})).to eq("{}")
    end

    it "returns a valid JSON string when given valid data" do
      json = JSON.parse(text)

      expect(json).to eq({ "header1" => %w[name1 name2], "header2" => %w[space1 space2] })
    end
  end
end
