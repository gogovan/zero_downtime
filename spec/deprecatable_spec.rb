require 'support/models'

RSpec.describe ZeroDowntime::Deprecatable do
  class PersonWithNameDeprecated < ActiveRecord::Base # :nodoc:
    self.table_name = :people
    deprecate_column :name
  end

  class PersonWithNameDeprecatedAndNil < ActiveRecord::Base # :nodoc:
    self.table_name = :people
    deprecate_column :name, nil: true
  end

  class PersonWithFirstAndLastNamesDeprecated < ActiveRecord::Base # :nodoc:
    self.table_name = :people
    deprecate_column :first_name
    deprecate_column :last_name
  end

  class PersonWithoutDeprecation < ActiveRecord::Base # :nodoc:
    self.table_name = :people
  end

  let(:deprecated_class) { PersonWithNameDeprecated }
  let(:multi_deprecated_class) { PersonWithFirstAndLastNamesDeprecated }
  let(:undeprecated_class) { PersonWithoutDeprecation }

  describe 'with a deprecated column' do
    subject { deprecated_class }

    it 'ignores the column on create' do
      created = subject.create!
      expect(created.first_name).to eq 'unknown'
      expect(created.last_name).to eq 'unknown'
    end

    it "doesn't show the column name" do
      expect(subject.column_names).to(
        eq %w( id first_name last_name ))
    end

    context 'for an instance' do
      subject { deprecated_class.first }

      it 'has no reader for the deprecated column' do
        expect do
          subject.name
        end.to raise_error(ZeroDowntime::DeprecatedColumn)
      end

      context 'with the nil reader' do
        subject { PersonWithNameDeprecatedAndNil.first }

        it 'has the reader return nil' do
          expect(subject.name).to be_nil
        end
      end

      it 'has no writer for the deprecated column' do
        expect do
          subject.name = 'Tess'
        end.to raise_error(ZeroDowntime::DeprecatedColumn)
      end

      it 'skips the column from attributes' do
        expect(subject.attributes).to eq(
          'id' => subject.id,
          'first_name' => subject.first_name,
          'last_name' => subject.last_name
        )
      end

      it 'skips the column from attribute_names' do
        expect(subject.attribute_names).to eq(
          ['id', 'first_name', 'last_name']
        )
      end

      it "doesn't affect normal columns" do
        subject.first_name = 'Tessa'
        subject.save!
        subject.first_name
      end
    end
  end

  describe 'with multiple deprecated columns' do
    subject { multi_deprecated_class.first }

    it 'has no reader for either deprecated column' do
      expect do
        subject.first_name
      end.to raise_error(ZeroDowntime::DeprecatedColumn)

      expect do
        subject.last_name
      end.to raise_error(ZeroDowntime::DeprecatedColumn)
    end
  end

  describe 'without deprecated columns' do
    subject { undeprecated_class }

    it 'works as usual' do
      subject.count
      subject.all.to_a
      subject.first
    end

    context 'for an instance' do
      subject { undeprecated_class.first }

      it 'shows all the columns' do
        expect(subject.attributes).to eq(
          'id' => subject.id,
          'first_name' => subject.first_name,
          'last_name' => subject.last_name,
          'name' => subject.name
        )
      end

      it 'shows all columns for attribute_names' do
        expect(subject.attribute_names).to eq(
          ['id', 'name', 'first_name', 'last_name']
        )
      end
    end
  end

  describe 'removing the deprecated column' do
    it "doesn't break the class" do
      deprecated_class.all.to_a
      deprecated = deprecated_class.create!

      undeprecated_class.all.to_a
      undeprecated = undeprecated_class.create!

      ActiveRecord::Schema.define(version: 1) do
        remove_column :people, :name
      end

      deprecated_class.all.to_a
      deprecated_class.create!

      undeprecated_class.all.to_a

      #expect do
        undeprecated_class.create!
      #end.to raise_error(ActiveRecord::StatementInvalid)

      undeprecated.name = 'new name'
      expect do
        undeprecated.save!
      end.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
