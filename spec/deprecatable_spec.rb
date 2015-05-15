require 'support/models'

RSpec.describe ZeroDowntime::Deprecatable do

  class PersonWithNameDeprecated < ActiveRecord::Base
    self.table_name = :people
    deprecate_column :name
  end

  class PersonWithFirstAndLastNamesDeprecated < ActiveRecord::Base
    self.table_name = :people
    deprecate_column :first_name
    deprecate_column :last_name
  end

  class PersonWithoutDeprecation < ActiveRecord::Base
    self.table_name = :people
  end

  describe 'with a deprecated column' do
    subject { PersonWithNameDeprecated.new }

    it 'has no reader for the deprecated column' do
      expect do
        subject.name
      end.to raise_error(NoMethodError)
    end

    it 'has no writer for the deprecated column' do
      expect do
        subject.name = 'Tess'
      end.to raise_error(NoMethodError)
    end
  end

  describe 'with multiple deprecated columns' do
    subject { PersonWithFirstAndLastNamesDeprecated.new }

    it 'has no reader for either deprecated column' do
      expect do
        subject.first_name
      end.to raise_error(NoMethodError)

      expect do
        subject.last_name
      end.to raise_error(NoMethodError)
    end
  end
end
