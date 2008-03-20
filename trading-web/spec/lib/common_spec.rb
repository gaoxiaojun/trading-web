require File.dirname(__FILE__) + '/../spec_helper'

class Holder
  attr_accessor :nested
  
  def initialize nested=nil
    @nested = nested
  end
end

describe "Common Util extenssion for string, dates, money and similar" do

  it "should format Money into html representation with $ sign in front" do
    money = Money.new 234
    money.to_html.should == "<span class=\"\">2.34</span>"
    
    money = Money.new(-234)
    money.to_html.should == "<span class=\"red\">-2.34</span>"
  end
  
  it "should initialize Money from a string" do
    Money.new('2.34').should == Money.new(234)
  end
  
  it "should initialize Money from a string when white spaces" do
    Money.new('2 500 000').should == Money.new(250000000)
  end
  
  it "should initialize Money from a string when comma separators" do
    Money.new('2,500,000').should == Money.new(250000000)
  end
  
  it "should format Date into html representation like month, date, year" do
    date = Date.new 2005, 12, 31
    date.to_html.should == "12/31/2005"
  end
  
  it "Ojbect respond_to? method should accept nested properties" do
    holder3 = Holder.new
    holder2 = Holder.new holder3
    holder1 = Holder.new holder2
      
    holder1.nested_respond_to?('nested.nested').should be_true
  end
  
  it "Ojbect respond_to? method should return false when no such method" do
    holder1 = Holder.new Object.new
      
    holder1.nested_respond_to?('nested.nested').should be_false
  end
  
  it "Ojbect respond_to? method should accept symbol" do
    holder3 = Holder.new
    holder2 = Holder.new holder3
    holder1 = Holder.new holder2
      
    holder1.nested_respond_to?(:nested).should be_true
  end
  
  it "Ojbect respond_to? method should return false when some of the nested properties is not a method" do
    holder2 = Holder.new
    holder1 = Holder.new holder2
    holder3 = Holder.new

    holder1.nested_send('nested.nested=', holder3).should == holder3
  end
end