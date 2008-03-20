require File.dirname(__FILE__) + '/../spec_helper'

describe CompanyFinancial do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  it "every financial should have associated company" do
    himco = companies :himco
    himco_financials = company_financials :himco_financial
    
    himco.company_financial.should_not be_nil
    himco_financials.company.should_not be_nil
    
    himco_financials.company.should == himco
  end
end
