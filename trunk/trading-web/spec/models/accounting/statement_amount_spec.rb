require File.dirname(__FILE__) + '/../../spec_helper'

describe "Statement Amounts are part of a Statement. Consists of amount and account type" do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
 
  it "every amount should have amount" do
    statement_amount = statement_amounts :himco_statement_balance_sheet_jan_amount1
    
    statement_amount.amount.should_not be_nil
    statement_amount.amount.should be_instance_of(Money)
  end
  
 it "every amount should have associated account type" do
    statement_amount = statement_amounts :himco_statement_balance_sheet_jan_amount1
    
    statement_amount.account_type.should_not be_nil
    statement_amount.account_type.should be_kind_of(AccountType)
    statement_amount.account_type.should == AccountType.find(4)
  end
end
