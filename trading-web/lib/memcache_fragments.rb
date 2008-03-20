class MemCache
  
  def read(key,options=nil)    
    begin
      get(key)
    rescue 
      ActiveRecord::Base.logger.error("MemCache Error: #{$!}")      
    end
  end
  
  def write(key,content,options=nil)
    expiry = options && options[:expire] || 0
    begin
      set(key,content,expiry)
    rescue 
      ActiveRecord::Base.logger.error("MemCache Error: #{$!}")      
    end
  end
end

module ActionController
  module Caching
    module Fragments
      class UnthreadedMemoryStore
      end
      class MemoryStore < UnthreadedMemoryStore
      end
      class MemCacheStore < MemoryStore
        def read(name, options=nil)
          @data.read(name)
        end

        def write(name, value, options=nil)
          @data.write(name, value, options)
        end
      end
    end
  end
end