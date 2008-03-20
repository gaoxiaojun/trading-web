require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../domain_fountain'

describe SqlCommandType do
   
  it "should delegate to models top_movers method and combine the results" do
    class_type_mock = mock("some_class", :null_object => true)
    field_name = :some_field_name
    sqlCommandType = SqlCommandType.new :class_type => class_type_mock, :field_name => field_name
   
    class_type_mock.should_receive(:top_movers).with(field_name, 'DESC', 5).and_return([:first])
    class_type_mock.should_receive(:top_movers).with(field_name, 'ASC', 5).and_return([:second])
    
    sqlCommandType.top_movers.should == [:first, :second] 
  end
  
  it "should look up for existing instance" do
    SqlCommandType.look_up(SqlCommandType::CHANGE_PRICE.type_name.to_s).should == SqlCommandType::CHANGE_PRICE
    SqlCommandType.look_up('not_existing_type').should be_nil
  end
end
