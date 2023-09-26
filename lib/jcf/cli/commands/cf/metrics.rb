# frozen_string_literal: true

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
          option :org, aliases: ["-o"], required: true, type: :string, desc: "Choose an organization"
          option :name, aliases: ["-n"], type: :string, desc: "Choose a service instance name"

          # TODO: split this out into something else
          def call(**options)
            validate_options(options)

            orgs = options[:org].include?(",") ? options[:org].split(",") : [options[:org]]

            orgs.each do |org|
              org_guid = organizations.find { |o| o.name == org }.guid
              err.puts "Found org guid: #{org_guid}"

              # find all of the offerings
              offering_guid = service_offerings.find { |s| s.name == "postgres" }.guid
              err.puts "Found offering guid: #{offering_guid}"

              # find the plans for those gatherings
              plan_guids = service_plans.find_all do |plan|
                plan.relationships.service_offering.guid == offering_guid
              end.collect(&:guid)
              err.puts "Found plan guids: #{plan_guids.count}"

              # look up the instances that match the plans and org
              # "/v3/service_instances?organization_guids=${org_guids}&service_plan_guids=${plan_guids}"
              instances = JCF::CF::ServiceInstance.all(
                organization_guids: org_guid,
                service_plan_guids: plan_guids.join(",")
              )
              err.puts "Found instances: #{instances.count}"

              instances.reject! { |i| i.name != options[:name] } if options[:name]

              cw = JCF::AWS::CloudWatch.new
              values = []

              Thread.abort_on_exception = true
              # use a the number of processors as the number of threads
              instances.each_slice(Concurrent.processor_count) do |slice|
                threads = slice.collect do |instance|
                  service_plan = instance.relationships.service_plan.populate!
                  service_offering = service_plan.relationships.service_offering.populate!
                  service_broker = service_offering.relationships.service_broker.populate!

                  Thread.new do
                    m = JCF::CF::Metric.new
                    m.name = (instance.name || "")
                    m.region = ENV["AWS_REGION"]
                    m.organization = org
                    m.organization_guid = org_guid
                    space = spaces.find { |s| s.guid == instance.relationships.space.guid }
                    m.space = space.name
                    m.space_guid = space.guid
                    m.service_broker_name = service_broker.name
                    m.service_broker_guid = service_broker.guid
                    m.service_offering = service_offering.name
                    m.service_plan = service_plan.name
                    unless ENV["SKIP_AWS"]
                      err.puts "Getting storage used for #{instance.guid}"
                      m.storage_used = to_gb(cw.storage_used(guid: instance.guid) || "")
                      err.puts "Getting storage allocated for #{instance.guid}"
                      m.storage_allocated = to_gb(cw.storage_allocated(guid: instance.guid) || "")
                      err.puts "Getting storage free for #{instance.guid}"
                      m.storage_free = to_gb(cw.storage_free(guid: instance.guid) || "")
                      err.puts "Getting iops for #{instance.guid}"
                      m.iops = (cw.iops(guid: instance.guid).to_fs(:rounded, precision: 0) || "")
                      err.puts "Getting cpu for #{instance.guid}"
                      m.cpu = (cw.cpu(guid: instance.guid).to_fs(:rounded, precision: 0) || "")
                    end
                    values << m
                  end
                end.map(&:value)
              end

              values << JCF::CF::Metric.new if values.empty?
              out.puts formatter.format(values)
              err.puts "Done."
            end
          end

          private

          def validate_options(options)
            raise JCF::CLI::InvalidOptionError, "No organization given" unless options[:org]
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
            JCF::CF::ServiceBroker.all
          end

          def to_gb(bytes)
            Filesize.from("#{bytes} b").to("GB").to_fs(:rounded, precision: 2)
          rescue ArgumentError
            0
          end
        end
      end
    end
  end
end
