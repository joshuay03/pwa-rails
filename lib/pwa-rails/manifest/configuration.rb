# frozen_string_literal: true

require 'json'

require_relative 'member_builder'

module PWA
  module Manifest
    # This class is responsible for configuring and
    # generating the manifest.json file.
    class Configuration
      class << self
        def new
          super

          builder = member_builder
          if block_given?
            yield builder

            builder.validate!
            generate_manifest! builder
          end

          builder.manifest_hash
        end

        private

        def member_builder
          MemberBuilder.new
        end

        def generate_manifest! builder
          File.write 'manifest.json', JSON.pretty_generate(builder.manifest_hash)
        end
      end
    end
  end
end
