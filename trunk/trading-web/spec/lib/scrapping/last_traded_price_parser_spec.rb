require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/scrapping/last_traded_price_parser'
require File.dirname(__FILE__) + '/../../../lib/scrapping/scrap_bse'

describe LastTradedPriceParser do
  before(:each) do
    file = File.open File.dirname(__FILE__).to_s + "/search_results.html"
    @parser = LastTradedPriceParser.new file.readlines.to_s
    @object_for_deletion = []
  end 
  
  after(:each) do
    @object_for_deletion.each do |company|  
      log_exception do 
        #for some reason company.destroy doesn't delete stock_quotes during rspec. 
        #working otherwise. This is some kind of hack.
        ActiveRecord::Base.connection.execute("delete from stock_quotes where stock_quotes.trading_market_id = #{company.trading_markets.first.id}")
        ActiveRecord::Base.connection.execute("delete from trading_markets where trading_markets.company_id = #{company.id}")
        ActiveRecord::Base.connection.execute("delete from companies where companies.id = #{company.id}")
      end
    end
  end
  
  it "should extract last traded price and date together with stock symbol as key" do
    extracted_prices =  @parser.exctract_last_traded_prices
      
    specified_last_traded_prices = []
    specified_last_traded_prices.push({:stock_symbol =>'BMREIT', :volume=>"355995", 
        :last_traded_price => Money.new(305, 'BGN'), :price_avrg => Money.new(223, 'BGN'),
        :volume => '355995'})
    specified_last_traded_prices.push({:stock_symbol =>'HIMKO',  :volume=>"56934", 
        :last_traded_price => Money.new(15, 'BGN'),  :price_avrg => Money.new(21, 'BGN'),
        :volume => '56934'})
      
    for i in 0...specified_last_traded_prices.size 
      extracted_row = extracted_prices[i]
      expected_row = specified_last_traded_prices[i]
      expected_row.each do |key, value|
        extracted_row[key].should == value
      end
    end
      
    @parser.trading_date.should == Time.local(2007, 10, 27,0,0,0)
  end
     
  it "should asscociate last traded prices with a company based on stock symbol and store it" do
    bmreit = DomainFountain.create_company
     
    @object_for_deletion.push bmreit if bmreit.save
    bmreit.should be_valid
      
    bmreit_trading_market = DomainFountain.create_trading_market
    bmreit_trading_market.stock_symbol= 'BMREIT'
    bmreit_prev_close = bmreit_trading_market.last_traded_price
    bmreit.trading_markets<<bmreit_trading_market
    bmreit.save.should be_true
       
    himco = DomainFountain.create_company
    @object_for_deletion.push himco if himco.save
    himco.should be_valid
      
    himco_trading_market = DomainFountain.create_trading_market
    himco_trading_market.stock_symbol= 'HIMKO'
    himco_prev_close = himco_trading_market.last_traded_price
    himco.trading_markets<<himco_trading_market
       
    @parser.store_last_traded_prices
      
    bmreit = Company.find bmreit.id
    himco = Company.find himco.id
      
    timepoint = Time.local(2007, 10, 27, 0, 0, 0)
    verify_stock_quotes :company => bmreit, :price => Money.bg_money(305), :last_traded_date =>timepoint,
      :volume =>  355995, :price_avrg => Money.bg_money(223),  :prev_close => bmreit_prev_close
      
    verify_stock_quotes :company => himco,  :price => Money.bg_money(15),  :last_traded_date =>timepoint,
      :volume =>  56934,  :price_avrg => Money.bg_money(21),  :prev_close => himco_prev_close
  end
  
  it "should verify trading market" do
    msg = @parser.verify_market "not_existing_market_stock_symbol"
    msg.should =~ (/No Market/i)
     
    market = TradingMarket.build.and_save!
    msg = @parser.verify_market market.stock_symbol
    msg.should =~ (/Market #{market.stock_symbol} has not been updated/i)
  end
  
  it "should verify stock quote" do
    @parser.trading_date= Date.today
    StockQuote.build(:timepoint => @parser.trading_date).with_trading_market.and_save!
    StockQuote.build(:timepoint => @parser.trading_date).with_trading_market.and_save!
    msg = @parser.verify_stock_quotes_number
    msg.should =~ /Number of inserted stock quotes is \(2\)/
  end
  
  def verify_stock_quotes arg
    trading_market = arg[:company].trading_markets.first
    stock_quote = trading_market.stock_quotes.first
    stock_quote.price.should == arg[:price]
    stock_quote.timepoint.should == arg[:last_traded_date]
    stock_quote.trading_market_id.should == trading_market.id
    stock_quote.volume.should == arg[:volume]
    stock_quote.price_avrg.should == arg[:price_avrg]
    trading_market.price_avrg.should == arg[:price_avrg]
    trading_market.price_low.should == arg[:price]
    trading_market.price_high.should == arg[:price]
    trading_market.prev_close.should == arg[:prev_close]
  end
  
  def log_exception
    begin
      yield
    rescue Exception => e
      puts e
    end
  end 
end