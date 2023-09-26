# frozen_string_literal: true

require_relative "base"

module JCF
  module CF
    class Quota < Base
      self.endpoint = "organization_quotas"
    end
  end
end
