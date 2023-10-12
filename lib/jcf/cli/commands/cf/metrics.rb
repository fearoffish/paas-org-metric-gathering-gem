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
          argument :offering, required: true, values: %w[postgres mysql aws-s3-bucket],
                          desc: "Choose a service instance offering to query"

          option :template, aliases: ["-t"], required: true, type: :string,
                   desc: "Template for backend service instance names e.g. \"rdsbroker-{guid}-{name}\""
          option :values, aliases: ["-v"], required: false, type: :string, default: "",
                   desc: "Values for the template. 'guid' is the service instance guid e.g. \"name=test\""
          option :org, aliases: ["-o"], required: true, type: :string,
                       desc: "Choose an organization (can be multiple comma-separated)"
          option :name, aliases: ["-n"], type: :string, desc: "Choose a service instance name"

          def call(*_args, **options)
            validate_options(options)
            orgs = options[:org].include?(",") ? options[:org].split(",") : [options[:org]]

            orgs.each do |org|
              org_guid = organizations.find { |o| o.name == org }.guid
              err.puts "Found org guid: #{org_guid}"

              offering_guid = service_offerings.find { |s| s.name == options[:offering] }&.guid
              err.puts "Found offering guid: #{offering_guid}"

              unless offering_guid
                err.puts "No offerings found for type #{options[:offering]}"
                exit(1)
              end

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
              instances.select! { |i| i.name.include? options[:name] } if options[:name]
              err.puts "Found instances: #{instances.count}"

              cw = JCF::AWS::CloudWatch.new
              values = []

              Thread.abort_on_exception = true
              # use a the number of processors as the number of threads
              instances.each_slice(Concurrent.processor_count) do |slice|
                slice.collect do |instance|
                  service_plan = instance.relationships.service_plan.populate!
                  service_offering = service_plan.relationships.service_offering.populate!
                  service_broker = service_offering.relationships.service_broker.populate!

                  Thread.new do
                    m = JCF::CF::Metric.new
                    m.name = (instance.name || "")
                    err.puts "Getting metrics for #{m.name}"
                    m.region = ENV["AWS_REGION"]
                    m.deploy_env = options[:env]
                    m.organization = org
                    m.organization_guid = org_guid
                    space = spaces.find { |s| s.guid == instance.relationships.space.guid }
                    m.space = space.name
                    m.space_guid = space.guid
                    m.service_broker_name = service_broker.name
                    m.service_broker_guid = service_broker.guid
                    m.service_offering = service_offering.name
                    m.service_plan = service_plan.name

                    template = options[:template]
                    t_values = parse_values(options[:values], instance.guid)

                    if service_offering.name == "postgres"
                      m.storage_used = to_gb(cw.rds_storage_used(name: JCF::CLI.template_parser(template, t_values)) || "")
                        m.storage_allocated = to_gb(cw.storage_allocated(name: JCF::CLI.template_parser(template, t_values)) || "")
                        m.storage_free = to_gb(cw.storage_free(name: JCF::CLI.template_parser(template, t_values)) || "")
                        m.iops = (cw.iops(name: JCF::CLI.template_parser(template, t_values)).to_fs(:rounded, precision: 0) || "")
                        m.cpu = (cw.cpu(name: JCF::CLI.template_parser(template, t_values)).to_fs(:rounded, precision: 0) || "")
                    end

                    if service_offering.name == "aws-s3-bucket"
                      m.storage_used = to_gb(cw.s3_storage_used(name: JCF::CLI.template_parser(template, t_values)) || "")
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
