# == Schema Information
# Schema version: 18
#
# Table name: portfolio_withholdings
#
#  id                  :integer(11)     not null, primary key
#  portfolio_id        :integer(11)     not null
#  trading_market_id   :integer(11)     not null
#  transaction_type_id :integer(11)     not null
#  shares              :integer(11)     not null
#  date                :date            
#  price               :integer(11)     default(0)
#  currency            :string(255)     default("BGN")
#  pitch               :text            
#

class PortfolioWithholding < ActiveRecord::Base
  schema_validations :except => [:shares, :price]
  has_enumerated  :transaction_type
  belongs_to :trading_market
  moneys :price
  
  before_validation :validate_date_and_price
  validates_numericality_of :shares, :price, :on => :save, :only_integer => true, :allow_nil => false, :greater_than => 0
  
  validates_date :date, :after => Proc.new { Date.today }, :after_message => 'should be after today (%s)'
  
  after_validation :add_stock_symbol_msg
  
  
  def initialize(attributes=nil)
    stock_symbol = attributes.delete(:stock_symbol) if attributes
    super(attributes)
    self.market_stock_symbol= stock_symbol
  end
  
  def market_stock_symbol= stock_symbol
    return if stock_symbol.nil?
    self.trading_market= TradingMarket.find_by_stock_symbol stock_symbol
  end
  
  def stock_symbol
    self.trading_market.stock_symbol unless self.trading_market.nil?
  end
  
  def transaction_name
    self.transaction_type.name unless self.transaction_type.nil?
  end
  
  def default_date
    self.date = 1.day.from_now.to_date if self.date.nil?
    self.date
  end
  
  private #####################################################################################
  
  def add_stock_symbol_msg
    if self.errors.remove :trading_market_id
      self.errors.clear
      self.errors.add :stock_symbol, "is invalid!" 
    end
    
    if buy_transaction? and price_not_defined? and !stock_symbol.nil?
        self.errors.remove :price
        self.errors.add :price, " for this stock is not available. We are sorry for this inconvenience." 
    end
  end
  
  
  def validate_date_and_price
    self.price = Money::ZERO if self.price.nil?
    return unless buy_transaction?
    self.date = Date.today
    self.price = self.trading_market.last_traded_price
  end
  
  def buy_transaction?
    TransactionType[:Buy] == self.transaction_type
  end
  
  def price_not_defined?
    self.price.nil? or Money::ZERO == self.price
  end
end
