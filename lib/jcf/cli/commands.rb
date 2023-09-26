# frozen_string_literal: true

module JCF
  module CLI
    module Commands
    end

    def self.register_commands!
      register "version", Commands::Version, aliases: ["v", "-v", "--version"]
      register "metrics", Commands::CF::Metrics, aliases: ["m"]

      register "organizations", Commands::CF::Organizations, aliases: ["o", "orgs", "organizations"]
      register "spaces", Commands::CF::Spaces, aliases: ["s", "spaces"]
      register "brokers", Commands::CF::ServiceBrokers, aliases: ["br", "broker", "brokers"]
      register "instances", Commands::CF::ServiceInstances, aliases: ["i", "instance", "instances"]
      register "plans", Commands::CF::ServicePlans, aliases: ["p", "plan", "plans"]
    end
  end
end
