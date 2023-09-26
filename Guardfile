# More info at https://github.com/guard/guard#readme

directories(%w(exe lib spec))
  .select{ |d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist") }

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)
  watch(%r{^spec/support/fixtures/(.+)\.(json|yml|yaml)$}) { rspec.spec_dir }

  # Ruby files
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
end
