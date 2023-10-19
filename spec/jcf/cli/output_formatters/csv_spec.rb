# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::CSV do
  describe ".format" do
    let(:data) { { header1: ["name1", "name2"], header2: ["space1", "space2"] } }
    subject(:text) { described_class.format(data: data) }

    it "outputs \"\"' when given nil" do
      expect(described_class.format(data: nil)).to eq("")
    end

    it "outputs \"\" when given an empty hash" do
      expect(described_class.format(data: {})).to eq("")
    end

    describe "when given a hash" do
      it "has headers separated by a comma on line 1" do
        expect(line_number 1).to eq("header1,header2")
      end

      it "contains the first values on line 2" do
        expect(line_number 2).to eq("name1,space1")
      end

      it "contains the second values on line 3" do
        expect(line_number 3).to eq("name2,space2")
      end
    end
  end

  def line_number(number)
    text.split("\n")[number - 1]
  end
end
