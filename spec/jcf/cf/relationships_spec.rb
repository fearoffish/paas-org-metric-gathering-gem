# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe JCF::CF::Relationships do
  let(:orgs_hash) do
    {
      organizations: {
        data: [{
          guid: "test-organization-0-guid",
          name: "test-organization-0-name"
        }, {
          guid: "test-organization-1-guid",
          name: "test-organization-1-name"
        }]
      }
    }
  end
  let(:org_hash) { { organization: { data: orgs_hash[:organizations][:data].first } } }

  context "when acting enumerable" do
    subject(:enumerable) { described_class.new(nil, org_hash) }

    describe "#each" do
      it "creates corresponding objects for each key" do
        expect(enumerable).to all(be_an_instance_of(JCF::CF::Organization))
      end

      # describe "when the relationship has an array of results" do
      # end
    end

    describe "#count" do
      it "returns the count of relationships" do
        expect(enumerable.count).to eq(1)
      end
    end
  end

  describe "#initialize" do
    it "rejects objects that aren't a Hash" do
      expect { described_class.new(nil, []) }.to raise_error(ArgumentError)
    end

    it "accepts a hash" do
      expect { described_class.new({}) }.not_to raise_error
    end
  end

  describe "#relationship?" do
    subject(:relationship) { described_class.new(nil, org_hash) }

    it "returns true if the relationship exists" do
      expect(relationship.relationship?(:organization)).to be(true)
    end

    it "returns false if the relationship doesn't exist" do
      expect(relationship.relationship?(:not_a_relationship)).to be(false)
    end
  end

  describe "#respond_to_missing?" do
    subject(:missing) { described_class.new(nil, org_hash) }

    it "returns true if the relationship exists" do
      expect(missing.respond_to?(:organization)).to be(true)
    end

    it "returns false if the relationship doesn't exist" do
      expect(missing.respond_to?(:not_a_relationship)).to be(false)
    end
  end

  describe "#method_missing" do
    describe "with one relationship" do
      subject(:one) { described_class.new(nil, org_hash) }

      it "returns the relationship if it exists" do
        expect(one.organization).to be_a(JCF::CF::Organization)
      end

      it "raises an error if the relationship doesn't exist" do
        expect { one.not_a_relationship }.to raise_error(NoMethodError)
      end
    end

    describe "with two relationships" do
      subject(:two) { described_class.new(nil, orgs_hash) }

      it "returns two relationships" do
        expect(two.organizations.count).to be 2
      end

      it "returns Organizations" do
        expect(two.organizations).to all(be_a(JCF::CF::Organization))
      end
    end
  end

  describe "when populating," do
    subject(:populated) { described_class.new(nil, org_hash) }

    before { stub_curl("organizations") }

    it "populates the organization name and relationships" do
      expect(populated.organization.populate!.name).to eq(test_name(JCF::CF::Organization))
    end
  end
end
# rubocop:enable Metrics/BlockLength
