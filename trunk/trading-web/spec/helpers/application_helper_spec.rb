require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  it "should present stock price change az 0 in black when no price change or it is 0" do
    number_change_html(nil).should == 0
    number_change_html(0).should == 0
    number_change_html('not a number').should == 0
  end
  
  it "should present stock price change in green with '+' sign when positive amount" do
     number_change_html(1).should == "<span class='green'>+1.00</span>"
     number_change_html(1.00).should == "<span class='green'>+1.00</span>"
     number_change_html(1.34567).should == "<span class='green'>+1.35</span>"
     number_change_html(Money.new(134.567)).should == "<span class='green'>+1.35</span>"
  end
  
  it "should present stock price change in red with '-' sign when negative amount" do
     number_change_html(-1).should == "<span class='red'>-1.00</span>"
     number_change_html(-1.00).should == "<span class='red'>-1.00</span>"
     number_change_html(-1.34567).should == "<span class='red'>-1.35</span>"
     number_change_html(Money.new(-134.567)).should == "<span class='red'>-1.35</span>"
  end
  
  it "should remove (+) or (-) sign for percentage and show it as (%n)" do
    parenthesize=true
    show_percent("<span class='red'>+23.34</span>", parenthesize).should == "<span class='red'>(%23.34)</span>"
    show_percent("<span class='red'>-23.34</span>", parenthesize).should == "<span class='red'>(%23.34)</span>"
    
    parenthesize = false
    show_percent("<span class='red'>-23.34</span>", parenthesize).should == "<span class='red'>%23.34</span>"
  end
end
