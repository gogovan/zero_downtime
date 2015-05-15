require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define(version: 0) do
  create_table :people, force: true do |t|
    t.string :name, :first_name, :last_name, default: 'unknown'
  end
end

class Person < ActiveRecord::Base
end

Person.create!(name: 'Test Ting', first_name: 'Tess', last_name: 'Ting')

require 'zero_downtime/deprecatable'
require 'pry'
ActiveRecord::Base.send :include, ZeroDowntime::Deprecatable
