# == Schema Information
# Schema version: 18
#
# Table name: stock_quotes
#
#  id                :integer(11)     not null, primary key
#  trading_market_id :integer(11)     not null
#  timepoint         :datetime        not null
#  volume            :integer(11)     
#  price_avrg        :integer(11)     
#  price             :integer(11)     not null
#  currency          :string(5)       not null
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  lock_version      :integer(11)     default(0), not null
#

class StockQuote < ActiveRecord::Base
  belongs_to :trading_market
  
  moneys :price, :price_avrg
  
  after_save :update_trading_market_last_traded_price
   
  def market_stock_symbol= stock_symbol
    self.trading_market= TradingMarket.find_by_stock_symbol stock_symbol
    raise "Stock Quote with price: #{price} and timepoint: #{formatted_timepoint} can't associate with existing trading market:  #{stock_symbol}!" if not self.trading_market
  end
   
  def to_s
    super + "=> price: #{price}, timepoint: #{formatted_timepoint}, trading_market_id #{trading_market_id}"
  end
   
  def validate
    not_unique = StockQuote.exists? :trading_market_id => self.trading_market_id, :timepoint => self.timepoint
    errors.add :timepoint ,  ActiveRecord::Errors.default_error_messages[:taken] if not_unique
  end
  
  def formatted_timepoint
    timepoint.nil? ? 'nil': timepoint.strftime('%Y_%m_%d')
  end
  
  def update_trading_market_last_traded_price
    self.trading_market.update_last_trade self
  end
  
   def self.last_traded_date_sql_cond last_traded_date
    [' stock_quotes.timepoint = (SELECT sq.timepoint FROM stock_quotes sq WHERE sq.timepoint <= ? ORDER BY sq.timepoint DESC  LIMIT 1) ', last_traded_date]
  end
  
  def self.top_movers field_name, order_direction, limit
    sql_cond = last_traded_date_sql_cond Time.now.strftime('%Y-%m-%d')
    sql = ["SELECT trading_markets.company_id, trading_markets.stock_symbol, stock_quotes.#{field_name} FROM stock_quotes, trading_markets  WHERE stock_quotes.trading_market_id = trading_markets.id AND #{sql_cond[0]} ORDER BY  #{field_name}  #{order_direction} LIMIT #{limit};", sql_cond[1]]
    find_by_sql sql 
  end 
end
