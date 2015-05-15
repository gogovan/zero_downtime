require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.string :name, :first_name, :last_name
  end
end

require 'zero_downtime/deprecatable'

ActiveRecord::Base.send :include, ZeroDowntime::Deprecatable
