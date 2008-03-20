module Test
  module Builder
    include Inflector
    TEST_ATTRIBUTES = YAML.load_file("spec/builders/test_attributes.yml")
    
    module ClassMethods
  
      def build new_attr = {}
        attr = test_attributes.merge new_attr
        props = attr.delete :__send__
        obj = self.new uniquefy_attrs_for_test(attr)
        props.each{|key, value| obj.send("#{key}=", value)} if props
        obj
      end
   
      def test_attributes
        attr = TEST_ATTRIBUTES[self.name]
        attr ||= {}
      end
   
      @@increment = 0
      def unique_index_for_test
        time = Time.now.hash
        @@increment+=1
        time + @@increment
      end
      
      def short_unique_index
         short_index = unique_index_for_test.to_s
         short_index = short_index[-6..-1]  if short_index.size > 6
         short_index
      end
   
      def uniquefy_attrs_for_test attr
        attr.each do |key, value|
          if value.respond_to?(:gsub)
            if value =~ /@@unique_index@@/
              attr[key]= value.gsub(/@@unique_index@@/, unique_index_for_test.to_s )
            elsif value =~ /@@short_unique_index@@/
               attr[key]= value.gsub(/@@short_unique_index@@/, short_unique_index ) 
            end
          end
        end
        attr
      end
      
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  
    def attach_to obj
      obj.send(extract_has_many_name_from(self)) << self 
      belongs_to_test_associations << obj
      self
    end
    
    def method_missing(method, *arguments, &block)
      method_name = method.to_s
      case method_name
      when /^with_/
        return with_(method_name, *arguments)
      when /^adding_/
        return adding_(method_name, *arguments)
      end
     
      super
    end
    
    def and_save
      save_test_associations
      save 
      self
    end
    
    def and_save!
      save_test_associations
      save!
      self
    end
  
    def with_ method_name, *arguments
      method_name =  method_name.gsub(/^with_/,'')
      saved = extract_saved? method_name
      arg = arguments[0] || constantize(camelize(method_name)).build
      arg = arg.and_save! if saved
      self.send("#{method_name}=", arg) 
      belongs_to_test_associations << arg
      self
    end
    
    def adding_ method_name, *arguments
      method_name =  method_name.gsub(/^adding_/,'')
      saved = extract_saved? method_name
      arg = arguments[0] || constantize(camelize(method_name)).build
      arg = arg.and_save! if saved
      method_name = pluralize method_name
      self.send(method_name) << arg
      self
    end
    
    private
    
    def save_test_associations
      belongs_to_test_associations.each do |obj|
        obj.and_save
        puts "ERROR WHILE SAVING:::::::::::::::::::::::: \n #{obj.errors.inspect}" unless obj.valid?
      end 
    end
    
    def belongs_to_test_associations
      @belongs_to_test_associations ||= []
      @belongs_to_test_associations
    end
    
 
    def extract_belongs_to_name_from obj
      underscore  obj.class.name
    end
    
    def extract_has_many_name_from obj
      pluralize extract_belongs_to_name_from(obj)
    end
    
    def extract_saved? method_name
      method_name.gsub!(/^saved_/,'')
    end
  end
end