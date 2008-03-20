require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/data_conversion/populate_market_stock_volume'

describe PopulateMarketStockVolume do
  EXPECTED_MARKETS = {
    'ADVEQ' => {:nominal => Money.new(100), :nominal_currency => 'BGN', :stock_volume => 11984284}, 
    'AFH'   => {:nominal => Money.new(200), :nominal_currency => 'BGN', :stock_volume => 2356923}, 
    'AGROF' => {:nominal => Money.new(100), :nominal_currency => 'EUR', :stock_volume => 16137954}
  }
  
  before(:each) do
    @object_for_deletion = []
    company = DomainFountain.create_company
    company.save!
    
    EXPECTED_MARKETS.each do |stock_symbol, values|
      market =  DomainFountain.create_trading_market
      market.stock_symbol = stock_symbol
      market.company = company
      market.save!
      values[:id] = market.id
      @object_for_deletion << market
    end
    
    @object_for_deletion << company
  end
  
       after(:each) do
    @object_for_deletion.each {|obj| obj.destroy}
  end
  
 
  it "should populate all company statement amounts rows successfully." do
    PopulateMarketStockVolume.securities_file=  '/../../spec/lib/data_conversion//All_issues-ENG.txt'
    PopulateMarketStockVolume.populate
    
    EXPECTED_MARKETS.each do |stock_symbol, values|
      market = TradingMarket.find values[:id]
      values.each do |symbol, value|
        market.send(symbol).should == value
      end
    end
  end

end