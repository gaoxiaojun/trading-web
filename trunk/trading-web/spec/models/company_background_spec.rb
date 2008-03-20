require File.dirname(__FILE__) + '/../spec_helper'

describe "Company Background consists of city, tax_no, activity, branch and is associated with a company " do
   fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  it "every background should have associated company" do
    himco = companies :himco
    himco_background = company_backgrounds :himco_background
    
    himco.company_background.should_not be_nil
    himco_background.company.should_not be_nil
    
    himco_background.company.should == himco
  end
end
