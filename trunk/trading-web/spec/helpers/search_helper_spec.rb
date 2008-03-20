require File.dirname(__FILE__) + '/../spec_helper'

describe "Search Helper should mark(bolded) the partial search term in the returned search results" do
  include SearchHelper

  it "should return an empty string when null results" do
    selected_matches('search_term', nil).should ==  ""
  end
  
  it "should select/<strong> first matching substring when mathing ALL letters" do
    result = selected_matches("ser", [["se", "se"],["reservice","reservice"] , ["service","service"], ["ser","ser"], ["not matching","not matching"]])
    result.should == "<ul><li>se<span class='informal'>, se</span></li><li>re<strong>ser</strong>vice<span class='informal'>, re<strong>ser</strong>vice</span></li><li><strong>ser</strong>vice<span class='informal'>, <strong>ser</strong>vice</span></li><li><strong>ser</strong><span class='informal'>, <strong>ser</strong></span></li><li>not matching<span class='informal'>, not matching</span></li></ul>"
  end
  
  it "should select matching substring while ingnoring letter cases" do
      result = selected_matches 'Ser', [['service','service']]
      result.should == "<ul><li><strong>ser</strong>vice<span class='informal'>, <strong>ser</strong>vice</span></li></ul>"
  end
end
