require 'zero_downtime/deprecatable'

begin
  require 'rails/railtie'

  module ZeroDowntime
    class Railtie < Rails::Railtie # :nodoc:
      initializer 'zero_downtime.initialize' do
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Base.send :include, Deprecatable
        end
      end
    end
  end
rescue LoadError
  warn "can't load railtie"
end
