# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
#ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '1.2.3'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '/../lib/memorize_finder')
require File.join(File.dirname(__FILE__), '/../lib/enumerated.rb')
require File.join(File.dirname(__FILE__), '/../lib/common.rb')
require File.join(File.dirname(__FILE__), '/../lib/memcache_fragments')

require 'memcache'

#memcache: http://wiki.rubyonrails.org/rails/pages/HowtoChangeSessionStore
#memcache_fragments: http://agilewebdevelopment.com/plugins/memcache_fragments_with_time_expiry

memcache_options = {
   :compression => false,
   :debug => false,
   :namespace => "app-#{RAILS_ENV}",
   :readonly => false,
   :urlencode => false
}
memcache_servers = [ '127.0.0.1:11212']

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += Dir["#{RAILS_ROOT}/app/models/*/"] 

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  #config.active_record.observers = :cacher, :garbage_collector
  

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_controller.fragment_cache_store = :mem_cache_store, memcache_servers, memcache_options
  #ActionController::Base.fragment_cache_store = :mem_cache_store, "localhost"
  config.action_controller.session = { :session_key => "_myapp_session", :secret => "some secret phrase of at least 30 characters" }
end

cache_params = *([memcache_servers, memcache_options].flatten)
CACHE = MemCache.new(*cache_params)

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
 $KCODE = "UTF8"
 
#ActiveSupport::JSON.unquote_hash_key_identifiers = false

################################### Mail Settings #################################      
ActionMailer::Base.delivery_method = :sendmail #(:smtp (default), :sendmail, and :test)
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25,
  :domain => "opentrade.bg",
  :authentication => :plain, #(:plain, :login, :cram_md5)
  :user_name      => nil, 
  :password       => nil
}

ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t -f system@openTrade.bg'
}