require File.dirname(__FILE__) + '/../spec_helper'

describe "StockQuote class with fixtures loaded" do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
  
  it "should retrieve all two stock quotes" do
    StockQuote.should have(2).records
  end
  
  it "should have valid timepoint and price" do
    himco_stock = stock_quotes :himco_stock_1
    
    himco_stock.timepoint.should == (Time.local(2006, 10, 26, 0, 0, 0))
    himco_stock.price.should == Money.new(243234, 'BGN') 
  end 
  
  it "should validate requiring of timepoint, price and associated trading market" do
    validate_presence_of(StockQuote, [:price, :timepoint, :trading_market_id, :currency])
  end
  
  it "should associate with trading market" do
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => Time.local(2006, 10, 26, 0, 0, 0)
    stock_quote.trading_market= trading_markets :market_A
    
    stock_quote.trading_market.should_not be_nil
  end
  
  it "should not allowed storing of a new stock quote with same time point for same trading market" do
    himco_stock = stock_quotes :himco_stock_1
    duplicate_himco_stock = StockQuote.new :price => himco_stock.price, :timepoint => himco_stock.timepoint, :trading_market_id => himco_stock.trading_market_id
    
    duplicate_himco_stock.save
    
    duplicate_himco_stock.should_not be_valid
    duplicate_himco_stock.errors[:timepoint].should == (ActiveRecord::Errors.default_error_messages)[:taken]
  end
  
  it "should associates with trading market through stock symbol number" do
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => Time.local(2006, 10, 21, 0, 0, 0)
    
    market_A = trading_markets :market_A
    stock_quote.market_stock_symbol= market_A.stock_symbol
    
    stock_quote.trading_market.should_not be_nil
    stock_quote.trading_market.should == market_A
  end
  
  it "should raise exception and not associates with trading market when no trading market for given stock symbol number" do
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => Time.local(2006, 10, 23, 0, 0, 0)
    
    lambda {stock_quote.market_stock_symbol= 'FFF'}.should raise_error(Exception)
  end
  
  it "should NOT update the last traded price for the associated trading market when trade date is before last trade date for the market." do
    market_A = trading_markets :market_A
     
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => Time.local(2006, 10, 25, 0, 0, 0)
    stock_quote.trading_market= market_A
     
    stock_quote.trading_market.should_receive(:update_last_trade).with(stock_quote)
     
    stock_quote.save!
  end
end
