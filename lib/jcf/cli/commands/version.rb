# frozen_string_literal: true

module JCF
  module CLI
    module Commands
      class Version < Command
        desc "Print JCF app version"

        def call(*)
          require "jcf/version"
          out.puts "v#{JCF::VERSION}"
        end
      end
    end
  end
end
