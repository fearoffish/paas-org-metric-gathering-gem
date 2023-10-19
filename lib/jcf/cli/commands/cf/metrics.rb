# frozen_string_literal: true

# TODO: THIS IS A PROTOTYPE, REDO THIS INTO SOMETHING LESS SCRIPTY

require "shellwords"
require_relative "../../errors"
require "active_support"
require "active_support/core_ext/numeric/conversions"
require "filesize"
require "concurrent"

module JCF
  module CLI
    module Commands
      module CF
        class Metrics < Command
          argument :broker, required: true,
            desc: "Choose a service instance offering to query. Get the broker name from the command: jcf sb"
          argument :iaas_plugin, aliases: ["-m"], required: true, type: :string,
            values: ::JCF::Plugins.plugins.keys.collect(&:to_s),
            desc: "Select a IaaS plugin this broker is backed by"

          option :template, aliases: ["-t"], required: true, type: :string,
            desc: "Template for backend service instance names e.g. \"rdsbroker-{guid}-{name}\""
          option :values, aliases: ["-v"], required: false, type: :string, default: "",
            desc: "Values for the template. 'guid' is the service instance guid e.g. \"name=test\""
          option :org, aliases: ["-o"], required: true, type: :string,
            desc: "Choose an organization (can be multiple comma-separated)"
          option :name, aliases: ["-n"], type: :string, desc: "Choose a service instance name"

          def call(*_args, **options)
            validate_options(options)
            JCF.plugin options[:iaas_plugin].to_sym
            plugin = JCF::Plugins.plugins[options[:iaas_plugin].to_sym]

            orgs = options[:org].include?(",") ? options[:org].split(",") : [options[:org]]

            brokers = service_brokers.select { |b| b.name == options[:broker] }
            # find the offerings for those brokers
            offerings = service_offerings.select do |o|
              brokers.find { |b| b.guid == o.relationships.service_broker.guid }
            end
            if offerings && offerings.empty?
              err.puts "No offerings found for broker #{options[:broker]}"
              exit(1)
            end
            err.puts "Found #{offerings.count} offerings"

            orgs.each do |org|
              org_guid = organizations.find { |o| o.name == org }.guid
              err.puts "Found org guid: #{org_guid}"

              # find the plans for those offerings
              plan_guids = service_plans.find_all do |plan|
                offerings.collect(&:guid).include? plan.relationships.service_offering.guid
              end.collect(&:guid)
              err.puts "Found plan guids: #{plan_guids.count}"
              if plan_guids.empty?
                err.puts "No plans found for offerings"
                exit(1)
              end

              # look up the instances that match the plans and org
              # "/v3/service_instances?organization_guids=${org_guids}&service_plan_guids=${plan_guids}"
              instances = JCF::CF::ServiceInstance.all(
                organization_guids: org_guid,
                service_plan_guids: plan_guids.join(",")
              )
              instances.select! { |i| i.name.include? options[:name] } if options[:name]
              err.puts "Found instances: #{instances.count}"

              values = {}

              Thread.abort_on_exception = true
              instances.each_slice(Concurrent.processor_count) do |slice|
                slice.collect do |instance|
                  service_plan = instance.relationships.service_plan.populate!
                  service_offering = service_plan.relationships.service_offering.populate!
                  service_broker = service_offering.relationships.service_broker.populate!

                  Thread.new do
                    metrics = {}
                    metrics[:name] = (instance.name || "")
                    metrics[:instance_guid] = instance.guid
                    err.puts "Getting metrics for #{instance.name}"
                    metrics[:region] = ENV["AWS_REGION"]
                    metrics[:organization] = org
                    metrics[:organization_guid] = org_guid
                    space = spaces.find { |s| s.guid == instance.relationships.space.guid }
                    metrics[:space] = space.name
                    metrics[:space_guid] = space.guid
                    metrics[:service_broker_name] = service_broker.name
                    metrics[:service_broker_guid] = service_broker.guid
                    metrics[:service_offering] = service_offering.name
                    metrics[:service_plan] = service_plan.name

                    template = options[:template]
                    t_values = parse_values(options[:values], instance.guid)

                    t = JCF::CLI.template_parser(template, t_values)
                    plugin.new(name: t).metrics.each do |k, v|
                      metrics[k] = v
                    end
                    values[instance.guid] = metrics
                  end
                end.each(&:join)
              end

              # values = { guid: { name: "name", space: "space" }, guid2: { name: "name2", space: "space2" } }
              # output = { header1: %w[name1 name2], header2: %w[space1 space2]}
              output = Hash.new { |hash, key| hash[key] = [] }
              values.each do |guid, metrics|
                metrics.each do |k, v|
                  output[k] << v
                end
              end

              out.puts formatter.format(data: output)
              err.puts "Done."
            end
          end

          private

          def validate_options(options)
            raise JCF::CLI::InvalidOptionError, "No organization given" unless options[:org]
          end

          def parse_values(values, guid)
            values = values.split(",")
            values << "guid=#{guid}"
            values.join(",")
          end

          def organizations
            @organizations ||= JCF::CF::Organization.all
          end

          def spaces
            @spaces ||= JCF::CF::Space.all
          end

          def service_instances
            @service_instances ||= JCF::CF::ServiceInstance.all
          end

          def service_plans
            @service_plans ||= JCF::CF::ServicePlan.all
          end

          def service_offerings
            @service_offerings ||= JCF::CF::ServiceOffering.all
          end

          def service_brokers
            @service_brokers ||= JCF::CF::ServiceBroker.all
          end
        end
      end
    end
  end
end
