# frozen_string_literal: true

module JCF
  module CLI
    module Commands
    end

    def self.register_commands!
      register "version", Commands::Version, aliases: ["v", "-v", "--version"]
      register "metrics", Commands::CF::Metrics, aliases: ["m"]

      register "organizations", Commands::CF::Organizations, aliases: %w[o orgs organization]
      register "spaces", Commands::CF::Spaces, aliases: %w[s space]
      register "users", Commands::CF::Users, aliases: %w[u user]
      register "services", Commands::CF::Services
      register "service_brokers", Commands::CF::ServiceBrokers, aliases: %w[sb service_broker]
      register "service_offerings", Commands::CF::ServiceOfferings, aliases: %w[so service_offering]
      register "service_instances", Commands::CF::ServiceInstances, aliases: %w[si service_instance]
      register "service_plans", Commands::CF::ServicePlans, aliases: %w[sp service_plan]
    end
  end
end
