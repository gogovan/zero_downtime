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

    class_methods do
      # deprecate a given column
      # so it will be ignore by activerecord
      # we can remove it once the deprecation is deployed
      def deprecate_column(column_name)
        deprecate_column_reader(column_name)
        deprecate_column_writer(column_name)

        self.deprecated_columns ||= []
        deprecated_columns << column_name.to_s
      end

      def columns_with_deprecations
        all_columns = columns_without_deprecations
        return all_columns unless deprecated_columns

        all_columns.reject { |c| deprecated_columns.include?(c.name) }
      end

      private

      def deprecate_column_reader(column_name)
        define_method(column_name) do
          fail DeprecatedColumn, "attempted to read #{column_name}"
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
