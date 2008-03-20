require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../domain_fountain'

describe Company do
 fixtures :users, :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
 it "should have associated company type" do
    himco = companies :himco
    
    himco.type.should == CompanyType[:INVESTMENT]
  end
  
  it "associating not valid company type to a company should be allowable (should not raise exception)" do
    bulbank = companies :bulbank
    
    bulbank.type.should == CompanyType[:BANKING]
    lambda {bulbank  = CompanyType[:NOT_EXISTING]}.should_not raise_error
  end
  
  it "should be associate successfully with a valid company type" do
    pharma = companies :pharma
    
    pharma.type.should_not be_nil
    pharma.type.should == CompanyType[:INDUSTRY]
    
    pharma.type = :BANKING
    
    pharma.type.should_not be_nil
    pharma.type.should == CompanyType[:BANKING]
  end
  
  it "should have many trading markets" do
    himco = companies :himco
    
    himco.trading_markets.should_not be_empty
    market_A = himco.trading_markets.first
    
    market_A.should be_instance_of(TradingMarket)
  end
  
  #VALIDATION
  it "should validate requiring of company name, bul stat and company type" do
    validate_presence_of Company, [:name, :bul_stat, :type]
  end
  
  it "should validate numericality of company bul_stat field" do
    company = create_valid_company_object
    company.bul_stat = 'something not a number'
    
    company.should_not be_valid
    company.errors.should be_invalid(:bul_stat)
    
    company.errors[:bul_stat].should == ActiveRecord::Errors.default_error_messages[:not_a_number]
  end
  
  it "should validate uniqueness of company name and bul_stat fields" do
    same_company1 = create_valid_company_object
    same_company2 = create_valid_company_object
    same_company2.name= same_company1.name
    same_company2.bul_stat= same_company1.bul_stat
    
    same_company1.save
    same_company2.save
    
    same_company2.should_not be_valid
    
    same_company2.errors.should be_invalid(:name)
    same_company2.errors.should be_invalid(:bul_stat)
    
    same_company2.errors[:name].should == ActiveRecord::Errors.default_error_messages[:taken]
    same_company2.errors[:bul_stat].should == ActiveRecord::Errors.default_error_messages[:taken]
  end
  
  it "should return the official stock symbol that doesn't have R(d) in the name" do
    company = Company.new
  
    company.instance_eval do
      def trading_markets
        market1 = DomainFountain.create_trading_market
        market1.stock_symbol= 'R1ABCD'
        market2 = DomainFountain.create_trading_market
        market2.stock_symbol= 'ABCD'
        [market1, market2]
      end
    end
  
    company.default_stock_symbol.should == 'ABCD'
  end
  
  it "should return the market with the latest price change." do
    latest_market = trading_markets :market_A
    himco = companies :himco
    
    himco.latest_updated_market.should == latest_market
  end
  
  it "should set stock symbol on association with new market." do
    himco = companies :himco
    himco.stock_symbol = nil
    himco.trading_markets.clear
    market = DomainFountain.create_trading_market
    
    himco.trading_markets << market
    
    himco.stock_symbol.should == market.stock_symbol
    
    himco = Company.find himco.id
    himco.stock_symbol.should == market.stock_symbol
  end
  
  #HELPER METHODS
  private
  def create_valid_company_object
    company = DomainFountain.create_company
    company.should be_valid
    company
  end
end
