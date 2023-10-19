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

  def self.plugin(plugin)
    plugin = JCF::Plugins.load_plugin(plugin) if plugin.is_a?(Symbol)
    validate_plugin!(plugin)
    plugin.load_dependencies(self, *args, &block) if plugin.respond_to?(:load_dependencies)
    plugin.configure(self, *args, &block) if plugin.respond_to?(:configure)
  end

  def self.validate_plugin!(plugin)
    puts "Validating plugin (#{plugin}) implementation conforms to interface" if ENV["DEBUG"]

    %i[metrics names values].each do |method|
      raise "Plugin does not conform to interface (missing method \"#{method.to_s}\")" \
        unless plugin.new(name: nil).respond_to?(method)
    end
  rescue JCF::CLI::NotLoggedInError => e
    puts e.message
    exit 1
  end

  module Plugins
    @plugins = {}

    def self.plugins
      @plugins
    end

    def self.load_plugin(name)
      return @plugins[name] if @plugins[name]

      puts "Loading plugin #{name}" if ENV["DEBUG"]
      require "jcf/plugins/#{name}"
      raise "Plugin didn't correctly register itself" unless @plugins[name]
      @plugins[name]
    end

    # Plugins need to call this method to register themselves:
    #
    #   JCF::Plugins.register_plugin :render, Render
    def self.register_plugin(name, mod)
      puts "Registering plugin #{name}" if ENV["DEBUG"]
      @plugins[name] = mod
    end
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

    extend Dry::CLI::Registry

    puts "Loading formatters..." if ENV["DEBUG"]
    register_formatters!
    puts "Loading commands..." if ENV["DEBUG"]
    register_commands!
  end
end
