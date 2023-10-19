# frozen_string_literal: true

RSpec.describe JCF::CF::Services do
  describe ".first" do
    let(:broker) { test_object("service_broker", JCF::CF::ServiceBroker) }
    let(:offering) { test_object("service_offering", JCF::CF::ServiceOffering) }
    let(:plan) { test_object("service_plan", JCF::CF::ServicePlan) }

    before do
      allow(JCF::CF::ServiceBroker).to receive(:first).and_return(broker)
      allow(JCF::CF::ServiceOffering).to receive(:all).and_return([offering])
      allow(JCF::CF::ServicePlan).to receive(:all).and_return([plan])
    end

    it "returns a hash" do
      expect(described_class.first(name: broker.name)).to be_a(Hash)
    end
  end
end
