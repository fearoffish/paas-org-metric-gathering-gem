# frozen_string_literal: true

RSpec.describe "CLI version", type: :aruba do
  before { run_command("jcf version") }

  it "returns the version number" do
    expect(last_command_started).to have_output(/#{JCF::VERSION}/o)
  end
end
