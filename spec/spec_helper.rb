# frozen_string_literal: true

require "jcf"
# require "aruba/rspec"

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # config.include Aruba::Api
  config.include JCF::CLI::Helpers

  config.before do
    JCF.cache.reset
  end
end
