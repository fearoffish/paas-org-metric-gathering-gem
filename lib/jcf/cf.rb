# frozen_string_literal: true

module JCF
  module CF
    def self.curl(endpoint, params: {})
      params[:per_page] ||= 5000 if params
      url = sanitize_url(endpoint, params)

      response = do_curl(url)

      raise(JCF::CLI::NotLoggedInError, response) if response == "\n" || response.include?("FAILED")

      JSON.parse(response).deep_symbolize_keys
    end

    def self.sanitize_url(endpoint, params)
      url = endpoint.dup
      url << "?#{params.to_query}" if params && params != {}
      url
    end

    def self.do_curl(url)
      JCF.cache.get_or_set("cf curl \"/v3/#{url}\"".parameterize) do
        $stderr.puts "cf curl \"/v3/#{url}\"" if ENV["DEBUG"]
        `cf curl \"/v3/#{url}\"`
      end
    end
  end
end
