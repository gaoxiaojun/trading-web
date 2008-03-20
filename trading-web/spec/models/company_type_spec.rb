require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../enumerated_spec'

describe CompanyType do
  include Spec::EnumeratedSpec
  
  it "should retrieve all company types" do
    enumareted_records_size_should_be CompanyType, 9
  end
  
  it "should retrieve everry entry to be of CompanyType instance" do
    every_retrieved_enumerated_entry_should_be_instance_of CompanyType
  end
  
  it "should be with unique name" do
    every_enumerated_type_entry_should_be_with_unique_name CompanyType
  end
  
  it "should parse itself based on name" do
    CompanyType.parse('Bank - international and domestic', nil, nil, nil).should == CompanyType['BANKING']
  end
  
  it "should return default UNSPECIFIED when parse doesn't find matching name" do
    CompanyType.parse('international and domestic', nil, nil, nil).should == CompanyType['UNSPECIFIED']
  end
end
