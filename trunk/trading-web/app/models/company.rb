# == Schema Information
# Schema version: 18
#
# Table name: companies
#
#  id           :integer(11)     not null, primary key
#  type_id      :integer(11)     not null
#  name         :string(160)     not null
#  bul_stat     :integer(11)     not null
#  stock_symbol :string(8)       
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(11)     default(0), not null
#

class Company < ActiveRecord::Base 
  extend TextSearch
  
  acts_as_ferret  :fields => [ 'stock_symbols', 'name' ]
  
  has_enumerated  :type, :class_name => 'CompanyType'
  
  has_one :company_background, :dependent => :destroy
  
  has_one :company_financial,  :dependent => :destroy
  
  has_many   :trading_markets, :dependent => :destroy, 
    :after_add => :init_default_stock_symbol, :after_remove => :init_default_stock_symbol do
    
    def find_same_market(trading_market)
       return self.detect{|m| m.stock_symbol == trading_market.stock_symbol}
    end
 end
  
  has_many   :statements,      :dependent => :destroy do
    StatementType.find(:all).each do |type|
      memoized_finder type.method_like_name, "statement_type_id = #{type.id}"
    end
  end 
  
  validates_presence_of     :type
  validates_associated      :type
  validates_numericality_of :bul_stat, :on => :update, :only_integer => true, :allow_nil => false
  
  def stock_symbols
    trading_markets.collect {|market| market.stock_symbol}
  end
  
  def default_stock_symbol
    latest_market_change = nil
    trading_markets.each do |market|
      current_market =  market.latest_market_with_change latest_market_change
      latest_market_change = current_market unless current_market.stock_symbol.match(/^(R\d)/i)
    end
    
    latest_market_change ||= latest_updated_market
    if latest_market_change.nil?
      nil
    else
      latest_market_change.stock_symbol
    end
  end
  
 
  def latest_updated_market
    return TradingMarket.new if trading_markets.empty?
    latest_market_change = nil
    trading_markets.each do |market|
      latest_market_change = market.latest_market_with_change latest_market_change
    end
    
    latest_market_change
  end
  
  
  def trading_market
    return @trading_market if @trading_market
    @trading_market = latest_updated_market
  end
  
  @scaffold_columns = [ 
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "stock_symbol" }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "name" }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "sector",           :sort_sql => "type_id" }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "price",            :sort_sql => "trading_markets.last_traded_price" }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "price_change",     :sort_sql => "trading_markets.price_change" }),
    AjaxScaffold::ScaffoldColumn.new(self, { :name => "last_traded_date", :sort_sql => "trading_markets.last_traded_date" })
  ]
  
  def init_default_stock_symbol market=nil
    old_stock_symbol = self.stock_symbol
    self.stock_symbol= latest_updated_market.stock_symbol
    save unless self.stock_symbol == old_stock_symbol
  end
end

