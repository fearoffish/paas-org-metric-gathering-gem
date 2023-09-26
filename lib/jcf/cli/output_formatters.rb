# frozen_string_literal: true

module JCF
  module CLI
    module OutputFormatters
      def self.formatters
        @formatters ||= {}
      end

      def self.register_formatter(name, formatter)
        formatters[name] = formatter
      end

      def self.formatter(name)
        formatters[name]
      end
    end

    def self.register_formatters!
      Dir[File.join(__dir__, "output_formatters", "*.rb")].sort.each {|f| require f }
      OutputFormatters.constants.each do |c|
        OutputFormatters.register_formatter(c.to_s.downcase, OutputFormatters.const_get(c))
      end
    end
  end
end
