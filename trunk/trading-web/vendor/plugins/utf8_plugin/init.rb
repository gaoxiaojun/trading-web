$:.unshift File.dirname(__FILE__) + '/lib'

require 'actioncontroller_utf8'

$stderr.write("ActiveSupport::Multibyte wasn't loaded, normalization won't work\n") unless ''.respond_to?(:chars)

ActionController::Base.send(:include, ActionController::UTF8)
