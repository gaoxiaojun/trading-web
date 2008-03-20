require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../enumerated_spec'

describe StatementType do
  include Spec::EnumeratedSpec

  it "should retrieve all three statement types" do
    enumareted_records_size_should_be StatementType, 3
  end
  
  it "should be of statement type instance for every retrieved entry" do
    every_retrieved_enumerated_entry_should_be_instance_of StatementType
  end
  
  it "should be with unique name of statement for every enumerated statement type entry" do
    every_enumerated_type_entry_should_be_with_unique_name StatementType
  end
  
  it "should parse the Statement Type from the first symbol" do
    StatementType.parse('BS').should == StatementType['Balance Sheet']
    StatementType.parse('IS').should == StatementType['Income Statement']
    StatementType.parse('CF').should == StatementType['Cash Flow']
    
    StatementType.parse('Not Valid').should be_nil
  end
end
