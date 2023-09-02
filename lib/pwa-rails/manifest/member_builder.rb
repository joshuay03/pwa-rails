# frozen_string_literal: true

require_relative 'hash'

module PWA
  module Manifest
    # This class is responsible for building a PWA manifest
    # by configuring its members.
    class MemberBuilder
      class InvalidMemberError < StandardError; end

      ATTRIBUTES = {
        background_color: String,
        categories: Array,
        description: String,
        display: String,
        display_override: Array,
        file_handlers: Array,
        icons: Array
      }.freeze
      private_constant :ATTRIBUTES

      ATTRIBUTES.each_key { |attr| attr_writer attr }

      def validate!
        ATTRIBUTES.each do |attr, type|
          val = instance_variable_get "@#{attr}"
          next if val.nil? || val.is_a?(type)

          raise InvalidMemberError, "Expected #{attr} to be a #{type}, got #{val.class}"
        end
      end

      def manifest_hash
        instance_variables.each_with_object Manifest::Hash.new do |attr, m_hash|
          val = instance_variable_get attr
          cast_val = case val
                     when String, Array
                       val
                     end

          key = attr.to_s.delete '@'
          m_hash[key] = cast_val
        end
      end

      private

      ATTRIBUTES.each_key { |attr| attr_reader attr }
    end
  end
end
