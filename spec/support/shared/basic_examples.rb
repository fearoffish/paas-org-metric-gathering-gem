# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.shared_examples "basic" do
  let(:klass) { described_class.name.demodulize }
  let(:klass_single) { klass.underscore }
  let(:klass_plural) { klass.tableize }

  describe ".all" do
    subject(:all) { described_class.all }

    before { stub_curl(klass_plural) }

    it "returns an array" do
      expect(all).to be_an(Array)
    end

    it "to have a correct count" do
      json = fixture(klass_plural.to_s)
      count = json[:resources].count
      expect(all.length).to eq(count)
    end

    it "to be #{described_class}" do
      expect(all.first).to be_a(described_class)
    end

    it "to include a name of String" do
      expect(all.first.name).to be_a(String)
    end

    it "to include a guid of String" do
      expect(all.first.guid).to be_a(String)
    end
  end

  # TODO: actually test this, args aren't tested really
  describe ".all(name: name)" do
    it "will return #{described_class} objects" do
      stub_curl(klass_plural)

      resources = described_class.all(name: test_name(described_class))

      expect(resources).to all(be_a(described_class))
    end

    it "will return resources matching a name" do
      stub_curl(klass_plural)

      resources = described_class.all(name: test_name(described_class))
      names = resources.collect(&:name).uniq

      expect(names).to include(test_name(described_class))
    end
  end

  describe ".find_by name" do
    subject { described_class }

    before { stub_curl(klass_plural) }

    it "will return #{described_class} objects" do
      resources = subject.find_by(guid: test_name(described_class))
      classes = resources.collect(&:class).uniq

      expect(classes.all?(described_class)).to be true
    end
  end

  describe ".populate!" do
    subject { described_class.new(guid: test_guid(described_class)) }

    before { stub_curl(klass_plural) }

    it "returns #{described_class}" do
      expect(subject.populate!).to be_a(described_class)
    end
  end

  describe "#method_missing" do
    subject do
      described_class.create(
        name: json[:name],
        guid: json[:guid],
        relationships: json[:relationships]
      )
    end

    let(:json) { fixture(klass_single) }

    it "raises NoMethodError if no relationship exists" do
      expect { subject.not_me }.to raise_error(NoMethodError)
    end
  end
end
# rubocop:enable Metrics/BlockLength
