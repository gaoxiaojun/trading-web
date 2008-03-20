module ActiveRecord
  module Acts 
    module Enumerated 
      module InstanceMethods
        @method_like_name = nil
        
        def method_like_name
          @method_like_name = name.gsub(/\s/, '_').downcase.pluralize if @method_like_name.nil? 
          @method_like_name
        end  
      end
    end
  end
end  