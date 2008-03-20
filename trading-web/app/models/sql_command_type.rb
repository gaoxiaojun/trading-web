class SqlCommandType 
  attr_reader :type_name, :field_name, :class_type, :column_name, :format, :desc_top_title, :desc_bottom_title
 
  def initialize options
    @type_name = options[:type_name]
    @class_type = options[:class_type]
    @field_name = options[:field_name]
    @column_name = options[:column_name]
    @format = options[:format]
    @desc_top_title = options[:desc_top_title] || 'Gainers'
    @desc_bottom_title = options[:desc_bottom_title] || 'Losers'
  end
  
  def top_movers limit = 5
    begin
      high_movers = class_type.top_movers field_name, 'DESC', limit
      low_movers =  class_type.top_movers field_name, 'ASC',  limit 
      high_movers + low_movers
    rescue Exception=>e 
      ActiveRecord::Base.logger.error e
      []
    end
  end
  
  def to_s
    self.type_name.to_s
  end
  
  def self.look_up type_name
     TOP_MARKET_MOVERS_TYPES.detect{|t| t.to_s == type_name}
  end
  
  CHANGE_PRICE = SqlCommandType.new :type_name => :Price, :class_type => TradingMarket, :field_name => :price_change, :column_name => 'BGN', :format => Proc.new{|value| "number_change_html(#{value})"}
  CHANGE_PRICE_PERC = SqlCommandType.new :type_name => :Chg, :class_type => TradingMarket, :field_name => :price_change_percent, :column_name => 'Percent', :format => Proc.new{|value| "show_percent(number_change_html(#{value}), false )"}
  VOL = SqlCommandType.new :type_name => :Vol, :class_type => StockQuote, :field_name => :volume, :column_name => 'Qty', :format => Proc.new{|value| "#{value}"}, :desc_top_title => 'Most Active', :desc_bottom_title => 'Barely Participating'
  MKT_CAP = SqlCommandType.new :type_name => :Cap, :class_type => TradingMarket, :field_name => :market_cap, :column_name => 'BGN (TH)', :format => Proc.new{|value| "number_in_thousands(#{value})"},  :desc_top_title => 'Leaders', :desc_bottom_title => 'Happy Participants'
  
  TOP_MARKET_MOVERS_TYPES = [CHANGE_PRICE_PERC, CHANGE_PRICE, VOL, MKT_CAP]
end
