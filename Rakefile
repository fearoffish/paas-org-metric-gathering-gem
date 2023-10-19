# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "active_support/all"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc "Get all fixtures for an organization: rake get_fixtures[org_name]"
# rubocop:disable Layout/LineLength,Metrics/BlockLength
task :get_fixtures, [:org] do |_t, args|
  raise "Provide an organization name" if args[:org].empty?

  `mkdir -p spec/support/fixtures`

  json = curl("/v3/organizations?names=#{args[:org]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("organizations", json)
  org = ActiveSupport::JSON.decode(json).deep_symbolize_keys[:resources].first
  json = curl("/v3/organizations/#{org[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("organization", json)
  $stderr.puts "Found organization: #{org[:name]}"

  json = curl("/v3/organization_quotas?organization_guids=#{org[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("quotas", json)
  quotas = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  json = curl("/v3/organization_quotas/#{quotas[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("quota", json)
  $stderr.puts "Found quotas: #{quotas[:resources].count}"

  json = curl("/v3/users", debug: ENV.fetch("DEBUG", nil))
  # remove resources with a nil username
  users = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  users[:resources].reject! { |u| u[:username].nil? }
  write_fixture("users", json)
  json = curl("/v3/users/#{users[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("user", json)
  $stderr.puts "Found users: #{users[:resources].count}"

  # all spaces in our org
  json = curl("/v3/spaces?organization_guids=#{org[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("spaces", json)
  spaces = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  json = curl("/v3/spaces/#{spaces[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("space", json)
  $stderr.puts "Found spaces: #{spaces[:resources].count}"

  # only the rds-broker
  json = curl("/v3/service_brokers?names=rds-broker&per_page=5000", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_brokers", json)
  service_brokers = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  broker_guids = service_brokers[:resources].collect { |b| b[:guid] }
  $stderr.puts "Found service_brokers: #{service_brokers[:resources].count}"
  json = curl("/v3/service_brokers/#{service_brokers[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_broker", json)

  # all the offerings from the rds-broker
  json = curl("/v3/service_offerings?service_broker_guids=#{broker_guids.join(",")}&per_page=5000", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_offerings", json)
  service_offerings = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  offering_guids = service_offerings[:resources].collect { |b| b[:guid] }
  $stderr.puts "Found service_offerings: #{service_offerings[:resources].count}"
  json = curl("/v3/service_offerings/#{service_offerings[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_offering", json)

  # all the plans from the rds-broker offerings
  json = curl("/v3/service_plans?service_offering_guids=#{offering_guids.join(",")}&per_page=5000", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_plans", json)
  service_plans = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  plan_guids = service_plans[:resources].collect { |b| b[:guid] }
  $stderr.puts "Found service_plans: #{service_plans[:resources].count}"
  json = curl("/v3/service_plans/#{service_plans[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_plan", json)

  # all the instances of the rds-broker plans
  json = curl("/v3/service_instances?organization_guids=#{org[:guid]}&service_plan_guids=#{plan_guids.join(",")}&per_page=5000", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_instances", json)
  service_instances = ActiveSupport::JSON.decode(json).deep_symbolize_keys
  service_instances[:resources].collect { |b| b[:guid] }
  $stderr.puts "Found service_instances: #{service_instances[:resources].count}"
  json = curl("/v3/service_instances/#{service_instances[:resources].first[:guid]}", debug: ENV.fetch("DEBUG", nil))
  write_fixture("service_instance", json)

  # now let's sanitize all the names and guids
  # we can just use sed for this

  # change anything else that looks like a guid to a test-guid using ruby
  Dir.glob("spec/support/fixtures/*.json").each do |f|
    $stderr.puts "Sanitizing and relinking #{f}..."

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
      $stderr.puts "replacing #{space[:guid]} with test-space-#{i}-guid"
      $stderr.puts "replacing #{space[:name]} with test-space-#{i}-name"
      File.write(f, File.read(f).gsub(/#{space[:guid]}/, "test-space-#{i}-guid"))
      File.write(f, File.read(f).gsub(/#{space[:name]}/, "test-space-#{i}-name"))
    end

    users[:resources].each_with_index do |user, i|
      $stderr.puts "replacing #{user[:guid]} with test-user-#{i}-guid"
      $stderr.puts "replacing #{user[:username]} with test-user-#{i}-username"
      File.write(f, File.read(f).gsub(/#{user[:guid]}/, "test-user-#{i}-guid"))
      # File.write(f, File.read(f).gsub(%r/#{user[:username]}/, "test-user-#{i}-username"))
      # File.write(f, File.read(f).gsub(%r/#{user[:presentation_name]}/, "test-user-#{i}-username"))
    end

    File.write(f, File.read(f).gsub(/#{org[:guid]}/, "test-organization-0-guid"))
    File.write(f, File.read(f).gsub(/#{org[:name]}/, "test-organization-0-name"))

    File.write(f, File.read(f).gsub(/[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/, "other-guid"))
    File.write(f, File.read(f).gsub(/([a-z0-9-]+\.)+[a-z]{2,}/, "cf.example.com"))
  end

  # TODO: validate the files were gsubbed correctly-ish
  # $stderr.puts "Basic validation..."
  # %w[organization space service_broker service_offering service_plan service_instance].each do |resource|
  #   files = File.read(File.join(__dir__, "spec", "support", "fixtures", "#{resource.pluralize}.json"))
  #   file = File.read(File.join(__dir__, "spec", "support", "fixtures", "#{resource}.json"))

  #   json = ActiveSupport::JSON.decode(File.read(files)).deep_symbolize_keys
  #   json[:resources].each do |resource|
  #     json[:name].begin_with? "test-#{resource.underscore.dasherize}"
  #     json[:guid].begin_with? "test-#{resource.underscore.dasherize}"
  #   end
  # end

  $stderr.puts "Done."
end
# rubocop:enable Layout/LineLength,Metrics/BlockLength

def curl(url, debug: false)
  $stderr.puts "cf curl \"#{url}\"" if debug
  resp = `cf curl "#{url}" | jq .`
  $stderr.puts resp if debug
  resp
end

def write_fixture(name, contents)
  File.write("spec/support/fixtures/#{name}.json", contents)
end
