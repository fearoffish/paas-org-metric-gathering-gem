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
          load_plugins(plugin_dir)
          list_plugins
        end

        private

        def load_plugins(plugin_dir)
          Dir[plugin_dir].each do |plugin|
            out.puts "  file: #{File.basename(plugin, ".rb")}" if ENV["DEBUG"]
            JCF::Plugins.load_plugin(File.basename(plugin, ".rb").to_sym)
          end
        end

        def list_plugins
          JCF::Plugins.plugins.each do |plugin|
            out.puts "  #{plugin}"
          end
        end
      end
    end
  end
end
