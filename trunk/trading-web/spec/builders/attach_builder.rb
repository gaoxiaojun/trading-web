require 'spec/builders/builder'

ActiveRecord::Base.class_eval do
  include Test::Builder
end
