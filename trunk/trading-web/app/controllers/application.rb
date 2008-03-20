require 'auth_system'

# # Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#

class ApplicationController < ActionController::Base
  normalize_unicode_params :form => :kc
  include AuthSystem
  helper :auth
  before_filter :app_config, :ident_user
#  service :notification
  layout :change_when_print_preview
  

  # Used to be able to leave out the action
  def process(request, response)
    catch(:abort) do
      super(request, response)
    end
    response
  end

  def this_auth
    @app
  end
  helper_method :this_auth

#  caches_page :home, :companies, ""
  TRADING_COMPANY = "/trading_compaines/"
  
  def create_key parameters
    TRADING_COMPANY + params[:controller] << "/" << params[:action] <<"?"<<parameters.to_s
  end
  
  def cache_block parameters
    key = create_key parameters
    fragment = read_fragment(key)
    if expired? fragment
      write_fragment(key, [yield, expire_after_12_hours])
    else
      render :text => fragment[0]
    end
  end
  
  def cache_object name, id
    key = create_object_key name + id
    cached_object = read_fragment(key)
    if expired? cached_object
      cached_object = [yield(id), expire_after_12_hours]
      write_fragment(key, cached_object)
    end
      
    return cached_object[0]
  end
  
  def create_object_key parameters
    TRADING_COMPANY + "object:"+parameters
  end
  
  def expire_after_12_hours
    Time.at( Time.now.to_i + (12 * 60 * 60))
  end
  
  def expired? cached
    cached.nil? or cached[1] < Time.now
  end
  
  def show_in_print_preview
     @print_preview=true
  end
  
  def change_when_print_preview
    @print_preview? "print_preview" : "application"
  end
end