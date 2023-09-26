# frozen_string_literal: true

module JCF
  module CLI
    class Error < StandardError
    end

    class NotImplementedError < Error
    end

    class NotLoggedInError < StandardError
    end

    class InvalidOptionError < StandardError
    end
  end
end
