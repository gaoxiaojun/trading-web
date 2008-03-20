require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/data_conversion/convert_company_satements'
require File.dirname(__FILE__) + '/../../../lib/data_conversion/populate_account_types'

describe ConvertCompanyStatements do
  FILE_NAME = File.dirname(__FILE__).to_s + '/bse_extract_test.txt'
  
  before(:all) do
    @company1 = DomainFountain.create_company
    @company1.bul_stat = '131187474'
    @company1.save

    @market1 = DomainFountain.create_trading_market
    @market1.stock_symbol = 'ADVANC'
    @company1.trading_markets << @market1
  end
  
  it "should populate all company statement amounts rows successfully." do
     PopulatedAccountTypes.account_types_file=  '/../../spec/lib/data_conversion/account_types_test'
     PopulatedAccountTypes.populate
     
     ConvertCompanyStatements.populate FILE_NAME
     
     advanc_company = Company.find :first, :conditions => {:stock_symbol => 'ADVANC'}
     
     advanc_company.statements.size.should == 2
     advanc_company.statements.balance_sheets == 1
    
     
     advanc_company.statements.balance_sheets[0].statement_amounts == 3
     statement_amount = advanc_company.statements.balance_sheets[0].statement_amounts[1]
     statement_amount.amount.should == Money.bg_money(199775200)
     statement_amount.account_type.should == AccountType.find(:first, :conditions =>{:account_number=>"3-BS-1-1-1-2"})
  end

end