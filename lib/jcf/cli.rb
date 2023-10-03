# frozen_string_literal: true

require "dry/cli"
require "zeitwerk"
require "mini_cache"
require "active_support/inflector"

module JCF
  def self.root
    File.expand_path("..", __dir__)
  end

  def self.cache
    @cache ||= MiniCache::Store.new
  end

  module CLI
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        loader.inflector = Zeitwerk::GemInflector.new("#{JCF.root}/jcf.rb")
        loader.push_dir(JCF.root)
        loader.ignore(
          "#{JCF.root}/jcf/cli/{errors,version}.rb"
        )
        loader.inflector.inflect("jcf" => "JCF")
        loader.inflector.inflect("cf" => "CF")
        loader.inflector.inflect("cli" => "CLI")
        loader.inflector.inflect("url" => "URL")
        loader.inflector.inflect("json" => "JSON")
        loader.inflector.inflect("csv" => "CSV")
        loader.inflector.inflect("aws" => "AWS")
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # template parsing: "{guid}-{name}", "guid=1234,name=test"
    # TODO: add some form of validation and error handling
    def self.template_parser(template, values)
      result = template.dup

      (values || "").split(",").each do |value|
        key, val = value.split("=")
        result.gsub!("{#{key}}", val)
      end
      result
    end

    loader.setup
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.irregular "quota", "quotas"
    end

    require_relative "cli/output_formatters"
    require_relative "cli/commands"
    require_relative "cli/errors"
    # require_relative "cf.rb"
    require_relative "aws/cloudwatch"

    extend Dry::CLI::Registry

    register_formatters!
    register_commands!
  end
end
