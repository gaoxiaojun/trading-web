# == Schema Information
# Schema version: 18
#
# Table name: trading_markets
#
#  id                   :integer(11)     not null, primary key
#  company_id           :integer(11)     not null
#  market_name          :string(80)      not null
#  stock_symbol         :string(8)       not null
#  last_traded_price    :integer(11)     
#  last_traded_date     :datetime        
#  prev_close           :integer(11)     
#  price_high           :integer(11)     
#  price_low            :integer(11)     
#  price_avrg           :integer(11)     
#  price_change         :integer(11)     default(0), not null
#  price_change_percent :float           default(0.0), not null
#  currency             :string(5)       
#  stock_volume         :integer(11)     default(0), not null
#  nominal              :integer(11)     default(0), not null
#  market_cap           :integer(20)     default(0), not null
#  nominal_currency     :string(255)     default("BGN"), not null
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  lock_version         :integer(11)     default(0), not null
#

class TradingMarket  < ActiveRecord::Base
  belongs_to :company
  
  has_many   :stock_quotes,    :dependent => :destroy
  
  moneys :last_traded_price, :prev_close, :price_high, :price_low, :price_avrg, :price_change, :nominal, :market_cap
  
  before_validation :calculate_change
  
  def update_last_trade stock_quote
    if stock_quote and (self.last_traded_date.nil? or self.last_traded_date < stock_quote.timepoint)
      self.prev_close= self.last_traded_price
      self.last_traded_date= stock_quote.timepoint
      self.last_traded_price= stock_quote.price
      self.price_avrg= stock_quote.price_avrg
      check_price_high_for last_traded_price
      check_price_low_for  last_traded_price
      self.company.init_default_stock_symbol self
      save!
    end
  end
  
  def latest_market_with_change trading_market
    return self unless trading_market
    return self unless trading_market.last_traded_date
    return trading_market unless self.last_traded_date
    
    if self.last_traded_date > trading_market.last_traded_date 
      return self
    else
      return trading_market
    end
  end
  
  def update_market trading_market
    trading_market.class.money_prop.each do |symbol|
      value =  self.send symbol
      self.send symbol.to_s << '=', value 
    end
    self.last_traded_date= trading_market.last_traded_date
  end
  
  def calculate_change
    update_price_change_percent
    update_market_cap
  end
  
  def self.last_traded_date_sql_cond last_traded_date
    [' trading_markets.last_traded_date = (select tm.last_traded_date from trading_markets tm where tm.last_traded_date <= ? order by tm.last_traded_date desc  LIMIT 1) ', last_traded_date]
  end
  
  def self.top_movers field_name, order_direction, limit
    sql_cond = last_traded_date_sql_cond Time.now.strftime('%Y-%m-%d')
    sql = ["SELECT trading_markets.company_id, trading_markets.stock_symbol, trading_markets.#{field_name} FROM trading_markets, companies where trading_markets.company_id = companies.id AND  trading_markets.stock_symbol = companies.stock_symbol AND #{sql_cond[0]} ORDER BY  trading_markets.#{field_name}  #{order_direction} LIMIT #{limit};", sql_cond[1]]
    self.find_by_sql sql 
  end 
  
  private
  
  def check_price_high_for last_traded_price
    self.price_high=last_traded_price if self.price_high.nil? or self.price_high < last_traded_price
  end
  
  def check_price_low_for last_traded_price
    self.price_low=last_traded_price if self.price_low.nil? or self.price_low.zero? or self.price_low > last_traded_price
  end
  
  def update_price_change
    self.prev_close = Money::ZERO unless prev_close
    change = Money::ZERO 
    unless last_traded_price.nil? or last_traded_price.zero?
      change = last_traded_price - prev_close
    end
    self.price_change = change
    self.[]=(:price_change, change.cents)
    change
  end
  
  def update_price_change_percent
    change = update_price_change
    
    change_percent = 0
    unless change.zero?
      change_percent =((change.cents.to_f / last_traded_price.cents.to_f)*100)
    end
    self.price_change_percent = change_percent
    self.[]=(:price_change_percent, change_percent)
    change_percent
  end
  
  def update_market_cap
     self.stock_volume = 0 unless self.stock_volume
     self.last_traded_price= 0 unless self.last_traded_price
     self.market_cap = Money.new self.stock_volume*self.last_traded_price.cents
     self.[]=(:market_cap,  self.market_cap.cents)
  end
end
