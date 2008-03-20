# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails'
require 'lib/file_util'
require 'spec/domain_fountain'
require_all_files 'spec/builders'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  
  # Add more helper methods to be used by all tests here...
      
  def validate_presence_of(klazz, properties)
    instance = klazz.new 
    instance.should_not be_valid
  
    properties.each do |property| 
      instance.errors.should be_invalid(property)
      err_properties = instance.errors[property]
      if err_properties.is_a? Array
        err_properties.include?(ActiveRecord::Errors.default_error_messages[:blank]).should be_true
      else
        err_properties.should == ActiveRecord::Errors.default_error_messages[:blank] 
      end
    end 
  end
      
  def log_exception()
    begin
      yield
    rescue Exception => e
      puts e
    end
  end 
end
