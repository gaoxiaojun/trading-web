require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../enumerated_spec'

describe TransactionType do
  include Spec::EnumeratedSpec

  it "should retrieve all three transaction types" do
    enumareted_records_size_should_be TransactionType, 3
  end
  
  it "should be of TransactionType instance for every retrieved entry" do
    every_retrieved_enumerated_entry_should_be_instance_of TransactionType
  end
  
  it "should be with unique name of statement for every enumerated transaction type entry" do
    every_enumerated_type_entry_should_be_with_unique_name TransactionType
  end
  
  it "should return select options in value, name array" do
    types = TransactionType.select_options
    types[0][0].should == 'Buy'
    types[0][1].should == 'Buy'
    
    types[1][0].should == 'Right to Buy (Call Option)'
    types[1][1].should == 'Call'
    
    types[2][0].should == 'Right to Sell (Put Option)'
    types[2][1].should == 'Put'
  end
end
