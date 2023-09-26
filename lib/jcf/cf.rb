module JCF
  module CF
    def self.curl(endpoint, params: {})
      params[:per_page] ||= 5000 if params
      url = "#{endpoint}?#{params.to_query}" if params && params != {}

      response = JCF.cache.get_or_set("cf curl \"/v3/#{url}\"".parameterize) do
        puts "cf curl \"/v3/#{url}\"" if ENV["DEBUG"]
        `cf curl \"/v3/#{url}\"`
      end

      raise(JCF::CLI::NotLoggedInError, response) if response == "\n" || response.include?("FAILED")

      JSON.parse(response).deep_symbolize_keys
    end
  end
end
