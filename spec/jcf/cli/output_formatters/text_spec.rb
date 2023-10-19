# frozen_string_literal: true

RSpec.describe JCF::CLI::OutputFormatters::Text do
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
      it "resembles the top of a table on line 1" do
        expect(line_number 1).to include("┌")
        expect(line_number 1).to include("─┬")
        expect(line_number 1).to include("─┐")
      end

      it "contains the headers on line 2" do
        expect(line_number 2).to include("│header1")
        expect(line_number 2).to include("│header2")
      end

      it "resembles a header separator on line 3" do
        expect(line_number 3).to include("───────")
      end

      it "contains the first values on line 4" do
        expect(line_number 4).to include("│name1")
        expect(line_number 4).to include("│space1")
      end

      it "contains the second values on line 5" do
        expect(line_number 5).to include("│name2")
        expect(line_number 5).to include("│space2")
      end
    end
  end

  def line_number(number)
    text.split("\n")[number - 1]
  end
end
