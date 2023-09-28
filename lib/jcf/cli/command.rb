# frozen_string_literal: true

require "dry/cli"
require "active_support/core_ext/string/inflections"

module JCF
  module CLI
    class Command < Dry::CLI::Command
      module Output
        attr_reader :out, :err, :formatter

        def call(*args, **opts)
          @out = opts[:output] ? File.new(opts[:output], "w") : $stdout
          @err = $stderr
          output = opts[:format]
          @output_file = opts[:output]
          @formatter = OutputFormatters.formatter(output)

          super(*args, **opts)
        ensure
          @out.close if (@out && @out != $stdout)
        end
      end

      # mix in the global options
      def self.inherited(klass)
        super
        klass.option :format, aliases: ["--format"], default: "text", values: %w[text json csv], desc: "Output format"
        klass.option :output, aliases: ["--output"], desc: "Output file"

        klass.prepend(Output)
      end
    end
  end
end
