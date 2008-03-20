require File.dirname(__FILE__) + '/../spec_helper'

describe "Company has many statements." do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  before(:each) do
    @himco = companies :himco
  end
  
  it "company should have many statements" do
    @himco.statements.should_not be_empty
    
    statement1 = @himco.statements.balance_sheets.first
    
    statement1.should be_instance_of(Statement)
  end
  
  it "should filter out statements bazed on statement type" do
    balance_sheets = @himco.statements.balance_sheets
    
    balance_sheets.size.should == 2
    balance_sheets.each {|b| b.type.should == StatementType['Balance Sheet']}
    
    income_statements = @himco.statements.income_statements
    
    income_statements.size.should == 2
    income_statements.each {|s| s.type.should == StatementType['Income Statement']}
    
    cash_flow_statements = @himco.statements.cash_flows
    
    cash_flow_statements.size.should == 2
    cash_flow_statements.each {|s| s.type.should == StatementType['Cash Flow']}
  end
  
end
