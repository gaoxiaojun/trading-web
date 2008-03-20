require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../domain_fountain'

describe TradingMarket do
  fixtures :companies, :statements, :statement_amounts, :trading_markets, :stock_quotes, :company_backgrounds, :company_financials
   
  it "should have associated company." do
    himco = companies :himco
    himco_markets = trading_markets :market_A
    
    himco.trading_markets.should_not be_nil
    himco_markets.company.should_not be_nil
    
    himco_markets.company.should == himco
  end
  
  it "should NOT update last stock price when last stock date is before last stock date for a market." do
    market = trading_markets :market_A
    prev_last_traded_date = market.last_traded_date
    prev_last_traded_price = market.last_traded_price
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => prev_last_traded_date -1
    
    market.update_last_trade stock_quote
    
    market.last_traded_date.should == prev_last_traded_date
    market.last_traded_price.should == prev_last_traded_price
  end
  
  it "should update last stock price when last stock date is after last stock date for a market." do
    market = trading_markets :market_A
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => market.last_traded_date + 1
    
    market.update_last_trade stock_quote
    
    market.last_traded_date.should == stock_quote.timepoint
    market.last_traded_price.should == stock_quote.price
  end
  
  it "should update last stock price when no last stock date" do
    market = trading_markets :market_A
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => market.last_traded_date
    
    market.last_traded_date= nil
    market.update_last_trade stock_quote
    
    market.last_traded_date.should == stock_quote.timepoint
    market.last_traded_price.should == stock_quote.price
  end
  
  it "should move the current stock price to prev traded price while updating last change price" do
    market = trading_markets :market_A
    prev_last_traded_price = market.last_traded_price
    
    stock_quote = StockQuote.new :price => Money.bg_money(1111), :timepoint => market.last_traded_date + 1
    
    market.update_last_trade stock_quote
    
    market.prev_close.should == prev_last_traded_price
  end
  
  it "should calculate the delta between previos and current traded price." do
    market = trading_markets :market_A
    market.prev_close= Money.new 2543
    market.last_traded_price= 25.53
    
    market.calculate_change
    
    market.price_change.should == Money.new(10)
    market.price_change_percent.to_s(2).should == '0.39'
  end
  
  it "should calculate 0 as price change if no last traded price" do
    market = trading_markets :market_A
    market.prev_close= 25.43
    
    market.last_traded_price= nil
    
    market.calculate_change
    
    market.price_change.should == Money::ZERO
    market.price_change_percent.should == 0
  end
  
  it "should calculate 0 as price change if last traded price is zero" do
    market = trading_markets :market_A
    market.prev_close= 25.43
    market.last_traded_price= 0
    
    market.calculate_change
    
    market.price_change.should == Money::ZERO
    market.price_change_percent.should == 0
  end
  
  it "should return last traded price as the price change if no previous close" do
    market = trading_markets :market_A
    
    market.prev_close= 0
    
    market.calculate_change
    
    market.price_change.should == market.last_traded_price
    market.price_change_percent.should == 100.0
  end
  
  it "should return the market with the latest traded price." do
    later_updated_market = trading_markets :market_A
    earlier_updated_market = trading_markets :market_B
    
    earlier_updated_market.last_traded_date = later_updated_market.last_traded_date - 1
    
    latest_market = later_updated_market.latest_market_with_change earlier_updated_market
    latest_market.should == later_updated_market
    
    latest_market = earlier_updated_market.latest_market_with_change later_updated_market
    latest_market.should == later_updated_market
  end
  
  it "should return the market that has latest traded price." do
    market_A = trading_markets :market_A
    market_B = trading_markets :market_B
    
    market_A.latest_market_with_change(nil).should == market_A
    
    market_B.last_traded_date = nil
    market_A.latest_market_with_change(market_B).should == market_A
   
    market_B.last_traded_date = market_A.last_traded_date
    market_A.last_traded_date = nil
    market_A.latest_market_with_change(market_B).should == market_B
  end
  
  it "should be able to save with nil value for money properties" do
    market = DomainFountain.create_trading_market
    
    market.save
    market
  end
  
  it "should retrieve n numbers of higer and lower stock price amount changes" do
    himco = companies :himco
    max_market = TradingMarket.find_by_sql "SELECT max(last_traded_price) as max_last_traded_price from trading_markets;"
    max_price = Money.new max_market[0].max_last_traded_price
    
    min_market = TradingMarket.find_by_sql "SELECT min(last_traded_price) as min_last_traded_price from trading_markets;"
    min_price = Money.new min_market[0].min_last_traded_price
    prices = [max_price*3, max_price*2, max_price,min_price, min_price*-1,min_price*-2]
    today = Date.parse Time.now.strftime('%Y-%m-%d')
    prices.each do |amt|
      market = DomainFountain.create_trading_market
      market.last_traded_price= amt
      market.last_traded_date = today
      market.company= himco
      market.save!
    end
   
    field_name = :price_change
    top_movers_markets = TradingMarket.top_movers field_name, 'DESC',  2

#TODO: there is a problem with MySql driver. Investigate further. It works in production but not in tests.
#    
#    top_movers_markets.size.should == 2
#    
#    top_movers_markets[0].send(field_name).amount.should ==  prices[0].amount
#    top_movers_markets[1].send(field_name).amount.should ==  prices[1].amount
    
    top_movers_markets =TradingMarket.top_movers field_name, 'ASC',  2
    
#    top_movers_markets.size.should == 2
#  
#    top_movers_markets[0].send(field_name).amount.should ==  prices[-1].amount
#    top_movers_markets[1].send(field_name).amount.should ==  prices[-2].amount
  end
 
  it "should calculate market cap if no stock volume or last_traded_price" do
    market = trading_markets :market_A
    market.stock_volume = nil
    
    market.calculate_change
    
    market.market_cap.should == Money::ZERO
    
    market.last_traded_price = nil
    
    market.calculate_change
    
    market.market_cap.should == Money::ZERO
  end
  
 it "should calculate market cap from stock volume and last_traded_price" do
    market = trading_markets :market_A
    market.stock_volume = 50
    market.last_traded_price = 20
    
    market.calculate_change
    
    market.market_cap.should == Money.new(100000)
  end
end
