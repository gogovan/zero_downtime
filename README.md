# ZeroDowntime

[![Build Status](https://travis-ci.org/matthewrudy/zero_downtime.svg?branch=master)](https://travis-ci.org/matthewrudy/zero_downtime)

This is a minimal library to help run zero-downtime with rails and activerecord

## Deprecated Columns

The most common use case is deprecating a column.

If you just drop a column,
it will break any existing process that has cached the columns.

### Example

We have a model `Person`

It has a single column `:name`

However we want to split this up into

  * :first_name
  * :last_name

We add a migration

```
class AddFirstAndLastNamesToPeople < ActiveRecord::Migration
  class SafePersone # safe model
    self.table_name :people
  end

  def up
    add_column :people, :first_name
    add_column :people, :last_name

    SafePerson.find_each do |person|
      *first_names, last_name = person.name.split(" ")

      person.first_name = first_names.join(" ")
      person.last_name = last_name
      person.save!
    end
  end
end
```

That's fine,
but what to do with the deprecated :name column?

The answer, mark it as deprecated

```
class Person < ActiveRecord::Base
  deprecated_column :name
end
```

This will

* Let us easily find it later
* Stop anyone from using the column by accident
* Ensure that once its deployed we can safely remove the column
