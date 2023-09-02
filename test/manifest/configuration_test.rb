# frozen_string_literal: true

require "minitest/autorun"

require_relative "../../lib/pwa-rails/manifest/configuration"

module PWA
  module Manifest
    class ConfigurationTest < Minitest::Test
      def teardown
        FileUtils.rm_f("manifest.json")
      end

      def test_new_returns_an_empty_manifest_hash_when_not_given_a_block
        result = PWA::Manifest::Configuration.new

        assert_instance_of PWA::Manifest::Hash, result
        assert_equal({}, result)
      end

      def test_new_returns_a_manifest_hash_when_given_a_block
        result = PWA::Manifest::Configuration.new do |builder|
          builder.background_color = "red"
        end

        assert_instance_of PWA::Manifest::Hash, result
        assert_equal "red", result["background_color"]
      end

      def test_new_yields_a_member_builder_when_given_a_block
        PWA::Manifest::Configuration.new do |builder|
          assert_instance_of Manifest::MemberBuilder, builder
        end
      end

      def test_new_generates_a_json_manifest_file_when_given_a_block
        refute File.exist?("manifest.json")

        PWA::Manifest::Configuration.new {}

        assert File.exist?("manifest.json")
      end

      def test_new_raises_an_error_when_given_an_invalid_member
        expected_message = "Expected background_color to be a String, got Array"
        assert_raises Manifest::MemberBuilder::InvalidMemberError, match: expected_message do
          PWA::Manifest::Configuration.new do |builder|
            builder.background_color = [] # expecting a String
          end
        end

        expected_message = "Expected categories to be a Array, got String"
        assert_raises Manifest::MemberBuilder::InvalidMemberError, match: expected_message do
          PWA::Manifest::Configuration.new do |builder|
            builder.categories = "" # expecting an Array
          end
        end
      end

      def test_new_generates_a_json_manifest_file_with_the_correct_object_when_given_a_block
        PWA::Manifest::Configuration.new do |builder|
          builder.background_color = "red"
          builder.categories = ["books", "education", "medical"]
          builder.description = "Awesome application that will help you achieve your dreams."
          builder.display = "standalone"
          builder.display_override = ["fullscreen", "minimal-ui"]
          builder.file_handlers = [
            {
              action: "/handle-audio-file",
              accept: {
                'audio/wav': [".wav"],
                'audio/x-wav': [".wav"],
                'audio/mpeg': [".mp3"],
                'audio/mp4': [".mp4"],
                'audio/aac': [".adts"],
                'audio/ogg': [".ogg"],
                'application/ogg': [".ogg"],
                'audio/webm': [".webm"],
                'audio/flac': [".flac"],
                'audio/mid': [".rmi", ".mid"]
              }
            }
          ]
          builder.icons = [
            {
              src: "icon/lowres.webp",
              sizes: "48x48",
              type: "image/webp"
            },
            {
              src: "icon/lowres",
              sizes: "48x48"
            },
            {
              src: "icon/hd_hi.ico",
              sizes: "72x72 96x96 128x128 256x256"
            },
            {
              src: "icon/hd_hi.svg",
              sizes: "any"
            }
          ]
        end

        expected_manifest = JSON.parse(File.read("test/fixtures/manifest.json"))
        actual_manifest = JSON.parse(File.read("manifest.json"))
        assert_equal expected_manifest, actual_manifest
      end
    end
  end
end
