require File.dirname(__FILE__) + '/../../spec_helper'

describe "Statement consist of regulation date, audited and consolidated flags. Statment has Statement Type and Account Regulation Type." do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  it "should have associated statement type for every statement" do
    himco_statement = statements :himco_statement_balance_sheet_jan
    
    himco_statement.type.should == StatementType['Income Statement']
  end
  
  it "should be associate successfully with a valid statement type" do
    himco_statement = statements :himco_statement_income_jan
    
    himco_statement.type.should_not be_nil
    himco_statement.type.should == StatementType['Balance Sheet']
    
    himco_statement.type = 'Income Statement'
    
    himco_statement.type.should_not be_nil
    himco_statement.type.should == StatementType['Income Statement']
  end

  it "should have associated account regulatgion type" do
    himco_statement = statements :himco_statement_balance_sheet_jan
    
    himco_statement.account_regulation_type.should == AccountRegulationType['INDUSTRY']
  end
  
  it "should be associate successfully with a valid account regulation type" do
    himco_statement = statements :himco_statement_income_jan
    
    himco_statement.account_regulation_type.should_not be_nil
    himco_statement.account_regulation_type.should == AccountRegulationType[:INDUSTRY]
    
    himco_statement.account_regulation_type = :BANKING
    
    himco_statement.account_regulation_type.should_not be_nil
    himco_statement.account_regulation_type.should == AccountRegulationType[:BANKING]
  end
  
  it "should have many associated statement amounts" do
    himco_statement = statements :himco_statement_income_jan
    
    himco_statement.statement_amounts.should_not be_nil
    himco_statement.statement_amounts.should_not be_empty
  end
  
  it "should be the same if properties are equal" do
    statement = statements :himco_statement_income_jan
    
    statement.same?(:regulatory_date => Date.new(2007,1,8), :company_id => 1,
                    :statement_type_id =>2, :account_regulation_type_id => 2).should be_true
  end
  
   it "should not be the same if at least one property is not equal" do
    statement = statements :himco_statement_income_jan
    
    statement.same?(:regulatory_date => Date.new(2007,1,8), :company_id => 1,
                    :statement_type_id =>2, :account_regulation_type_id => 1).should be_false
  end
  
  #VALIDATION
  it "should validate requiring of regulatory date, statement type, account regulation type, audited and consolidated" do
    validate_presence_of Statement, [:regulatory_date, :audited, :consolidated, :type, :account_regulation_type]
  end
end
