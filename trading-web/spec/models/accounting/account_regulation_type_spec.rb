require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../enumerated_spec'

describe "Account Regulation Type defines the accounting rules for a company. One company could be associated with more than one account regulation type. Possible values (BANKING, INDUSTRY, INVESTMENT) " do
  include Spec::EnumeratedSpec
  
  it "should retrieve all three account regulation types" do
    enumareted_records_size_should_be AccountRegulationType, 3
  end
  
  it "every retrieved entry should be of Account Regulation type instance" do
    every_retrieved_enumerated_entry_should_be_instance_of AccountRegulationType
  end
  
  it "every enumerated statement type entry should be with unique account regulation name" do
    every_enumerated_type_entry_should_be_with_unique_name AccountRegulationType
  end
end
