# frozen_string_literal: true

require_relative "lib/jcf/version"

Gem::Specification.new do |spec|
  spec.name = "jcf"
  spec.version = JCF::VERSION
  spec.authors = ["Jamie van Dyke"]
  spec.email = ["me@fearof.fish"]

  spec.summary = "Gather metrics from AWS for CloudFoundry installations"
  spec.homepage = "https://github.com/fearoffish/paas-org-metric-gathering-gem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["github_repo"] = "ssh://github.com/fearoffish/paas-org-metric-gathering-gem"
  spec.metadata["source_code_uri"] = "https://github.com/fearoffish/paas-org-metric-gathering-gem"
  spec.metadata["changelog_uri"] = "https://github.com/fearoffish/paas-org-metric-gathering-gem/CHANGELOG"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 2.1"
  spec.add_dependency "dry-cli", "~> 1.0", "< 2"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.add_dependency "activemodel", "~> 7.0"
  spec.add_dependency "active_model_serializers", "~> 0.10"
  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "aws-sdk-cloudwatch", "~> 1.80"
  spec.add_dependency "aws-sdk-rds", "~> 1.80"
  spec.add_dependency "aws-sdk-s3", "~> 1.80"
  spec.add_dependency "concurrent-ruby", "~> 1.2"
  spec.add_dependency "csv", "~> 3.2"
  spec.add_dependency "english", "~> 0.7.2"
  spec.add_dependency "filesize", "~> 0.2.0"
  spec.add_dependency "mini_cache", "~> 1.1"
  spec.add_dependency "tty-table", "~> 0.12.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
