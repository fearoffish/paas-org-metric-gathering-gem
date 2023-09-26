# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

require "json"
require "active_support/core_ext/hash"
require "active_support/core_ext/string"
require "active_support/core_ext/object"
require "active_support/core_ext/string/inflections"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc "Get all fixtures for an organization: rake get_fixtures[org_name]"
task :get_fixtures, [:org] do |t, args|
  raise "Provide an organization name" if args[:org].empty?
  `mkdir -p spec/support/fixtures`

  json = curl("/v3/organizations?names=#{args[:org]}", debug: ENV["DEBUG"])
  write_fixture("organizations", json)
  org = JSON.parse(json).deep_symbolize_keys[:resources].first
  json = curl("/v3/organizations/#{org[:guid]}", debug: ENV["DEBUG"])
  write_fixture("organization", json)
  puts "Found organization: #{org[:name]}"

  json = curl("/v3/organization_quotas?organization_guids=#{org[:guid]}", debug: ENV["DEBUG"])
  write_fixture("quotas", json)
  quotas = JSON.parse(json).deep_symbolize_keys
  json = curl("/v3/organization_quotas/#{quotas[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("quota", json)
  puts "Found quotas: #{quotas[:resources].count}"

  # all spaces in our org
  json = curl("/v3/spaces?organization_guids=#{org[:guid]}", debug: ENV["DEBUG"])
  write_fixture("spaces", json)
  spaces = JSON.parse(json).deep_symbolize_keys
  json = curl("/v3/spaces/#{spaces[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("space", json)
  puts "Found spaces: #{spaces[:resources].count}"

  # only the rds-broker
  json = curl("/v3/service_brokers?names=rds-broker&per_page=5000", debug: ENV["DEBUG"])
  write_fixture("service_brokers", json)
  service_brokers = JSON.parse(json).deep_symbolize_keys
  broker_guids = service_brokers[:resources].collect { |b| b[:guid] }
  puts "Found service_brokers: #{service_brokers[:resources].count}"
  json = curl("/v3/service_brokers/#{service_brokers[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("service_broker", json)

  # all the offerings from the rds-broker
  json = curl("/v3/service_offerings?service_broker_guids=#{broker_guids.join(",")}&per_page=5000", debug: ENV["DEBUG"])
  write_fixture("service_offerings", json)
  service_offerings = JSON.parse(json).deep_symbolize_keys
  offering_guids = service_offerings[:resources].collect { |b| b[:guid] }
  puts "Found service_offerings: #{service_offerings[:resources].count}"
  json = curl("/v3/service_offerings/#{service_offerings[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("service_offering", json)

  # all the plans from the rds-broker offerings
  json = curl("/v3/service_plans?service_offering_guids=#{offering_guids.join(",")}&per_page=5000", debug: ENV["DEBUG"])
  write_fixture("service_plans", json)
  service_plans = JSON.parse(json).deep_symbolize_keys
  plan_guids = service_plans[:resources].collect { |b| b[:guid] }
  puts "Found service_plans: #{service_plans[:resources].count}"
  json = curl("/v3/service_plans/#{service_plans[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("service_plan", json)

  # all the instances of the rds-broker plans
  json = curl("/v3/service_instances?organization_guids=#{org[:guid]}&service_plan_guids=#{plan_guids.join(",")}&per_page=5000", debug: ENV["DEBUG"])
  write_fixture("service_instances", json)
  service_instances = JSON.parse(json).deep_symbolize_keys
  instance_guids = service_instances[:resources].collect { |b| b[:guid] }
  puts "Found service_instances: #{service_instances[:resources].count}"
  json = curl("/v3/service_instances/#{service_instances[:resources].first[:guid]}", debug: ENV["DEBUG"])
  write_fixture("service_instance", json)

  # now let's sanitize all the names and guids
  # we can just use sed for this

  # change anything else that looks like a guid to a test-guid using ruby
  Dir.glob("spec/support/fixtures/*.json").each do |f|
    puts "Sanitizing and relinking #{f}..."

    service_instances[:resources].each_with_index do |instance, i|
      File.write(f, File.read(f).gsub(/#{instance[:guid]}/, "test-service-instance-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{instance[:name]}/, "test-service-instance-#{i}-name"))
    end

    service_plans[:resources].each_with_index do |plan, i|
      File.write(f, File.read(f).gsub(/#{plan[:guid]}/, "test-service-plan-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{plan[:name]}/, "test-service-plan-#{i}-name"))
    end

    service_offerings[:resources].each_with_index do |offering, i|
      File.write(f, File.read(f).gsub(/#{offering[:guid]}/, "test-service-offering-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{offering[:name]}/, "test-service-offering-#{i}-name"))
    end

    service_brokers[:resources].each_with_index do |broker, i|
      File.write(f, File.read(f).gsub(/#{broker[:guid]}/, "test-service-broker-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{broker[:name]}/, "test-service-broker-#{i}-name"))
    end

    quotas[:resources].each_with_index do |quota, i|
      File.write(f, File.read(f).gsub(/#{quota[:guid]}/, "test-quota-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{quota[:name]}/, "test-quota-#{i}-name"))
    end

    spaces[:resources].each_with_index do |space, i|
      puts "replacing #{space[:guid]} with test-space-#{i}-guid"
      puts "replacing #{space[:name]} with test-space-#{i}-name"
      File.write(f, File.read(f).gsub(/#{space[:guid]}/, "test-space-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{space[:name]}/, "test-space-#{i}-name"))
    end

    File.write(f, File.read(f).gsub(/#{org[:guid]}/, "test-organization-0-guid"))
    File.write(f, File.read(f).gsub(/#{org[:name]}/, "test-organization-0-name"))

    File.write(f, File.read(f).gsub(/[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/, 'other-guid'))
    File.write(f, File.read(f).gsub(/([a-z0-9\-]+\.)+[a-z]{2,}/, 'cf.example.com'))
  end

  # TODO: validate the files were gsubbed correctly-ish
  # puts "Basic validation..."
  # %w[organization space service_broker service_offering service_plan service_instance].each do |resource|
  #   files = File.read(File.join(__dir__, "spec", "support", "fixtures", "#{resource.pluralize}.json"))
  #   file = File.read(File.join(__dir__, "spec", "support", "fixtures", "#{resource}.json"))

  #   json = JSON.parse(File.read(files)).deep_symbolize_keys
  #   json[:resources].each do |resource|
  #     json[:name].begin_with? "test-#{resource.underscore.dasherize}"
  #     json[:guid].begin_with? "test-#{resource.underscore.dasherize}"
  #   end
  # end

  puts "Done."
end

task :console do
  exec "irb -r ./lib/jcf.rb"
end

def curl(url, debug: false)
  puts "cf curl \"#{url}\"" if debug
  resp = `cf curl "#{url}" | jq .`
  puts resp if debug
  resp
end

def write_fixture(name, contents)
  File.open("spec/support/fixtures/#{name}.json", "w") do |f|
    f.write(contents)
  end
end