RSpec.shared_examples "basic" do
  let(:klass) { described_class.name.demodulize }
  let(:klass_single) { klass.underscore }
  let(:klass_plural) { klass.tableize }

  context "validations" do
    let(:valid_attrs) { { name: "name", guid: "guid", relationships: {} } }

    it "validates presence of a name" do
      valid_attrs[:name] = nil
      expect(described_class.new(**valid_attrs).valid?).to be_falsey
    end

    it "validates presence of a guid" do
      valid_attrs[:guid] = nil
      expect(described_class.new(**valid_attrs).valid?).to be_falsey
    end
  end

  context "caching" do
    before do
      stub_curl(klass_plural)
    end

    context ".all" do
      it "calls .all once and then uses the cache for every object" do
        expect(JCF.cache).to receive(:get_or_set).once.and_call_original

        described_class.find("test-space-2-guid")
      end
    end
  end

  context ".all" do
    before { stub_curl(klass_plural) }
    subject { described_class.all }

    it "return an array" do
      expect(subject).to be_an(Array)
    end

    it "to have a correct count" do
      json = fixture("#{klass_plural}")
      count = json[:resources].count
      expect(subject.length).to eq(count)
    end

    it "to be #{described_class}" do
      expect(subject.first).to be_a(described_class)
    end

    it "to include attributes" do
      expect(subject.first.name).to be_a(String)
      expect(subject.first.guid).to be_a(String)
    end
  end

  # TODO: actually test this, args aren't tested really
  context ".all(name: name)" do
    it "will return resources given a name" do
      stub_curl(klass_plural)

      resources = described_class.all(name: test_name(described_class))
      classes = resources.collect(&:class).uniq

      expect(classes.all? { |c| c == described_class }).to be true
    end

    it "will return resources matching a name" do
      stub_curl(klass_plural)

      resources = described_class.all(name: test_name(described_class))
      names = resources.collect(&:name).uniq

      expect(names).to include(test_name(described_class))
    end
  end

  context ".find_by name" do
    before { stub_curl(klass_plural) }
    subject { described_class }

    it "returns #{described_class}" do
      object = subject.find_by(guid: test_guid(described_class))
      expect(object).to be_a(described_class)
    end
  end

  context ".populate!" do
    before { stub_curl(klass_plural) }
    subject { described_class.new(guid: test_guid(described_class)) }

    it "returns #{described_class}" do
      expect(subject.populate!).to be_a(described_class)
    end
  end

  context "#method_missing" do
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
