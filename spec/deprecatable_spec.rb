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
    subject { PersonWithNameDeprecated.first }

    it 'has no reader for the deprecated column' do
      expect do
        subject.name
      end.to raise_error(ZeroDowntime::DeprecatedColumn)
    end

    it 'has no writer for the deprecated column' do
      expect do
        subject.name = 'Tess'
      end.to raise_error(ZeroDowntime::DeprecatedColumn)
    end

    it "doesn't affect normal columns" do
      subject.first_name = 'Tessa'
      subject.save!
      subject.first_name
    end
  end

  describe 'with multiple deprecated columns' do
    subject { PersonWithFirstAndLastNamesDeprecated.first }

    it 'has no reader for either deprecated column' do
      expect do
        subject.first_name
      end.to raise_error(ZeroDowntime::DeprecatedColumn)

      expect do
        subject.last_name
      end.to raise_error(ZeroDowntime::DeprecatedColumn)
    end
  end

end
