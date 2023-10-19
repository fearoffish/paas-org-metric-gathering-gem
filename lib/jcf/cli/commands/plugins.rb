# frozen_string_literal: true

module JCF
  module CLI
    module Commands
      class Plugins < Command
        desc "Show JCF plugins"

        def call(*)
          out.puts "JCF Plugins:"
          plugin_dir = File.join(JCF.root, "jcf", "plugins", "*.rb")
          pp "plugin dir: #{plugin_dir}" if ENV["DEBUG"]
          Dir[plugin_dir].each do |plugin|
            out.puts "  file: #{File.basename(plugin, ".rb")}" if ENV["DEBUG"]
            JCF::Plugins.load_plugin(File.basename(plugin, ".rb").to_sym)
          end
          JCF::Plugins.plugins.each do |plugin|
            out.puts "  #{plugin}"
          end
        end
      end
    end
  end
end
