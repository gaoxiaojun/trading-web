class DomainFountain
  @@increment = 0
  def self.create_company
    increment = unique_index
    Company.new :name =>"Some Name#{increment}", :bul_stat=>2343+ increment, :type_id => CompanyType[:BANKING].id
  end
  
  def self.create_company_with_trading_market
    company = create_company
    company.trading_markets.push create_trading_market
    company
  end
  
  def self.create_trading_market
    increment = unique_index 
     
    stock_symbol = increment.to_s
    stock_symbol = stock_symbol[-6..-1]  if stock_symbol.size > 6
    TradingMarket.new(:market_name => "Market A#{increment}", :stock_symbol=> "IN#{stock_symbol}", :last_traded_price=> Money.new(344), :last_traded_date => Date.new(2007,5,9))
  end
 
  private 
  def self.unique_index
    time = Time.now.hash
    @@increment+=1
    time + @@increment 
  end
end
