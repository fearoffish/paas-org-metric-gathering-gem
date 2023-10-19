# frozen_string_literal: true

require "aws-sdk-s3"
require "active_support/core_ext/integer/time"
require "active_support/isolated_execution_state"
require "filesize"

module JCF
  module Plugins
    class AwsS3
      def initialize(name:)
        @name = name
        @metrics = {}
        check_token!
      end

      def names
        %w[storage_used]
      end

      def values
        names.map { |name| send(name.to_sym) }
      end

      def metrics
        @metrics[:storage_used] = to_gb(s3_storage_used(name: @name || ""))
        @metrics
      end

      def to_s
        metrics.to_s
      end

      private

      def s3_storage_used(name:)
        s3 = Aws::S3::Client.new
        total_size = 0
        response = s3.list_objects_v2(bucket: name)
        response.contents.each do |object|
          total_size += object.size
        end
        total_size
      end

      def check_token!
        Aws::STS::Client.new.get_caller_identity({})
      rescue Aws::Errors::MissingCredentialsError
        raise JCF::CLI::NotLoggedInError, "Your AWS token has expired.  Please log in again."
      end

      def to_gb(bytes)
        Filesize.from("#{bytes} b").to("GB").to_fs(:rounded, precision: 2)
      rescue ArgumentError
        0
      end
    end

    register_plugin :aws_s3, AwsS3
  end
end
