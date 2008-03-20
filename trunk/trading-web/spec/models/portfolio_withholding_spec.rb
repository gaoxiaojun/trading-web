require File.dirname(__FILE__) + '/../spec_helper'

describe PortfolioWithholding do
  
  it "should save valid entry" do
    create_portfolio_withholding
       
    portfolio_withholdings = PortfolioWithholding.find :all 
    portfolio_withholdings.size.should == 1
    loaded_withholding = portfolio_withholdings[0]
       
    loaded_withholding.transaction_type.should == TransactionType[:Buy]
    loaded_withholding.trading_market.should_not be_nil
  end
    
  it "should initialize with stock symbol" do
    trading_market = TradingMarket.find(:all).first
    trading_market.should_not be_nil
    p_withholding = PortfolioWithholding.new(:shares => 22, :price => Money.new(234), 
      :transaction_type => TransactionType[:Buy], :trading_market => trading_market)
      
    p_withholding.trading_market_id.should  == trading_market.id
    p_withholding.shares.should == 22
    p_withholding.price.should == Money.new(234)
    p_withholding.transaction_type_id.should == TransactionType[:Buy].id
  end
    
  #VALIDATIONS ###############################################################
  it "should accept only positive numbers for shares" do
    create_portfolio_withholding :shares => -2
    should_not_be_valid_by :shares
  end
  
  it "should accept only positive amounts for stock price" do
    create_portfolio_withholding :price => -10
    should_not_be_valid_by :price
  end
  
  it "should have valid trading makret symbol" do
    create_portfolio_withholding :stock_symbol => 'NOT_PRESENTED'
    should_not_be_valid_by :stock_symbol
  end
  
  it "should accept only dates after today" do
    create_portfolio_withholding :date => 1.day.ago.to_date
    should_not_be_valid_by :date
  end
  
  it "should set today's date if none" do
    create_portfolio_withholding :date => nil
    @p_withholding.date.should == Date.today
  end
  
  it "should set price to last traded stock price when price nil or zero" do
    create_portfolio_withholding :price => nil
    @p_withholding.price.should_not be_nil
    @p_withholding.price.should == @p_withholding.trading_market.last_traded_price
  end
  
  
  private  ##########################################################################################
  def create_portfolio_withholding attrs = {}
     @p_withholding = PortfolioWithholding.build(attrs).attach_to(Portfolio.build.with_user).and_save
  end
  
  def should_not_be_valid_by  symbol
    @p_withholding.should_not be_valid
    @p_withholding.errors.size.should == 1
    @p_withholding.errors.should be_invalid(symbol)
  end
end
