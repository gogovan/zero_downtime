require 'active_support/concern'

module ZeroDowntime
  class DeprecatedColumn < RuntimeError
  end

  # Deprecatable adds the ability to deprecate columns
  # to ActiveRecord
  #
  #   class MyModel < ActiveRecord::Base
  #     deprecate_column :name
  #   end
  #
  module Deprecatable
    extend ActiveSupport::Concern

    included do
      class_attribute :deprecated_columns

      class << self
        alias_method_chain :columns, :deprecations
      end
    end

    module ClassMethods
      # deprecate a given column
      # so it will be ignore by activerecord
      # we can remove it once the deprecation is deployed
      def deprecate_column(column_name, options={})
        deprecate_column_reader(column_name, options)
        deprecate_column_writer(column_name)
        override_attribute_methods

        self.deprecated_columns ||= []
        deprecated_columns << column_name.to_s
      end

      def columns_with_deprecations
        all_columns = columns_without_deprecations
        return all_columns unless deprecated_columns

        all_columns.reject { |c| deprecated_columns.include?(c.name) }
      end

      private

      def override_attribute_methods
        return false if @attribute_methods_overriden

        class_eval do
          def attributes_with_deprecations
            attributes_without_deprecations.except(*self.class.deprecated_columns)
          end
          alias_method_chain :attributes, :deprecations

          def attribute_names_with_deprecations
            attribute_names_without_deprecations - self.class.deprecated_columns
          end
          alias_method_chain :attribute_names, :deprecations
        end
        @attribute_methods_overriden = true
      end

      def deprecate_column_reader(column_name, options)
        if options[:nil]
          define_method(column_name) do
            nil
          end
        else
          define_method(column_name) do
            fail DeprecatedColumn, "attempted to read #{column_name}"
          end
        end
      end

      def deprecate_column_writer(column_name)
        define_method("#{column_name}=") do |_|
          fail DeprecatedColumn, "attempted to write #{column_name}"
        end
      end
    end
  end
end
