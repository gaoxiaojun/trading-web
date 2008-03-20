require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../domain_fountain'

describe "Company Trading Markets Association." do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  before(:each) do
    @himco = companies :himco
  end
  
  it "should not find another associated trading market if stock symbol not presented" do
    trading_market = DomainFountain.create_trading_market
    
    @himco.trading_markets.find_same_market(trading_market).should be_nil
  end
  
  it "should find another associated trading market with same stock symbol" do
    himco_trading_market = trading_markets :market_A
    trading_market = DomainFountain.create_trading_market
    trading_market.stock_symbol = himco_trading_market.stock_symbol
    
    @himco.trading_markets.find_same_market(trading_market).should == himco_trading_market
  end
  
  
end
