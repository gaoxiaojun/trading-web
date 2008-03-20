module Spec
  module EnumeratedSpec
    def enumareted_records_size_should_be (enum_class, size)
      enum_class.should have(size).records
    end
    
    def every_retrieved_enumerated_entry_should_be_instance_of (enum_class)
      enum_types = enum_class.find(:all) 
      enum_types.should_not be_empty
      
      enum_types.each {|enum_type| enum_type.should be_instance_of(enum_class) }
    end
    
    def every_enumerated_type_entry_should_be_with_unique_name(enum_class)
      enum_types = enum_class.find(:all) 
      enum_types.should_not be_empty
      
      enum_type_names = Set.new
      enum_type_names.merge enum_types.collect {|enum_type| enum_type.name}
      
      enum_type_names.size.should == enum_types.size
    end
  end
end