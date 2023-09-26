# frozen_string_literal: true

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

  context "acting enumerable" do
    subject { described_class.new(nil, org_hash) }

    describe "#each" do
      it "creates corresponding objects for each key" do
        expect(subject).to all(be_an_instance_of(JCF::CF::Organization))
      end

      describe "when the relationship has an array of results" do
      end
    end

    describe "#count" do
      it "returns the count of relationships" do
        expect(subject.count).to eq(1)
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
    subject { described_class.new(nil, org_hash) }

    it "returns true if the relationship exists" do
      expect(subject.relationship?(:organization)).to eq(true)
    end

    it "returns false if the relationship doesn't exist" do
      expect(subject.relationship?(:not_a_relationship)).to eq(false)
    end
  end

  describe "#respond_to_missing?" do
    subject { described_class.new(nil, org_hash) }

    it "returns true if the relationship exists" do
      expect(subject.respond_to?(:organization)).to eq(true)
    end

    it "returns false if the relationship doesn't exist" do
      expect(subject.respond_to?(:not_a_relationship)).to eq(false)
    end
  end

  describe "#method_missing" do
    describe "with one relationship" do
      subject { described_class.new(nil, org_hash) }

      it "returns the relationship if it exists" do
        expect(subject.organization).to be_a(JCF::CF::Organization)
      end

      it "raises an error if the relationship doesn't exist" do
        expect { subject.not_a_relationship }.to raise_error(NoMethodError)
      end
    end

    describe "with two relationships" do
      subject { described_class.new(nil, orgs_hash) }

      it "returns the relationships if it exists" do
        expect(subject.organizations.count).to be 2
        expect(subject.organizations).to all(be_a(JCF::CF::Organization))
      end
    end
  end

  describe "when populating, " do
    subject { described_class.new(nil, org_hash) }
    before { stub_curl("organizations") }

    it "populates the organization name and relationships" do
      expect(subject.organization.populate!.name).to eq(test_name(JCF::CF::Organization))
    end
  end
end
