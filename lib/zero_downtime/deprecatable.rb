require 'active_support/concern'

module ZeroDowntime
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
      self.deprecated_columns = []
    end

    class_methods do

      # deprecate a given column
      # so it will be ignore by activerecord
      # we can remove it once the deprecation is deployed
      def deprecate_column(column_name)
        deprecated_columns << column_name.to_s
      end

      def columns
        super.reject { |c| deprecated_columns.include?(c.name) }
      end
    end
  end
end
