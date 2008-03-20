require 'rubygems'
require 'rubyful_soup'
require File.dirname(__FILE__) + '/base_scrapping_parser'

class LastTradedPriceParser
  include BaseScrappingParser
  attr_accessor :trading_date
  @@value_indexes = {0 => :stock_symbol, 4 => :volume, 6 => :last_traded_price, 8 => :price_avrg}
  
  def store_last_traded_prices
    @company_stocks = exctract_last_traded_prices
    @company_stocks.each do |last_stock_price|
      store last_stock_price
    end
  end
  
  def verify_last_traded_prices
    log_exception do
      not_updated_markets = ""
      index = 0;
      @company_stocks.each do |last_stock_price|
        msg = verify_market last_stock_price[:stock_symbol]
        unless msg.nil?
          index = index + 1
          not_updated_markets += "\n #{index}. "<< msg 
        end
      end
      verify_stock_quotes_number << not_updated_markets
    end
  end
  
  def verify_stock_quotes_number 
    count = StockQuote.count(:conditions => {:timepoint => @trading_date })
    msg = "Current trading date: #{@trading_date.strftime("%m/%d/%Y")} \nNumber of inserted stock quotes is (#{count}) out of (#{row_size})"
    @@logger.warn msg
    msg
  end
  
  def verify_market stock_symbol
    log_exception do
      market = TradingMarket.find_by_stock_symbol stock_symbol
      msg = nil
      if market.nil?
        msg = "No Market for Stock Symbol: #{stock_symbol}"
        @@logger.warn msg
        return msg
      end
      unless market.last_traded_date == @trading_date
        msg = "Market #{stock_symbol} has not been updated."
        @@logger.warn msg
      end 
      msg
    end
  end
  
  def extract_trading_date
    div = soup.find 'div'
    @trading_date = Date.parse_euro_date( div.to_s[/\d{2}.\d{2}.\d{4}/]).to_time
  end
  
  def exctract_last_traded_prices
    extract_trading_date
    rows = extract_rows 
    reset_soup
    
    company_stocks = []
    for i in 1...rows.length
      log_exception i do 
        company_stocks.push parse_row(rows[i]) if i%2 == 1
      end
    end
    
    @@logger.info "Rows extracted: #{company_stocks.size.to_s}"
    company_stocks
  end
  
  def to_s
    return super if not soup
    soup.to_s
  end
  
  def store_file?
    @fail_count.nil? || @fail_count < 20
  end
  private
  ################################### private ##################################
  def store last_stock_price
    stock_quote = StockQuote.new :price => last_stock_price[:last_traded_price], 
      :timepoint => @trading_date, :volume => last_stock_price[:volume], :price_avrg => last_stock_price[:price_avrg]
    begin
      begin
        stock_quote.market_stock_symbol= last_stock_price[:stock_symbol]
      rescue Exception => e
        @@logger.info ":::::::::::::::::: #{last_stock_price[:stock_symbol]} :::::::::::::::::::::::"
        @@logger.error e
        ScrapperMechanize.execute_companies_collect_web last_stock_price[:stock_symbol]
        stock_quote.market_stock_symbol= last_stock_price[:stock_symbol]
      end
      persist stock_quote
    rescue Exception => e
      @@logger.error "$$$$$$$ Exception for stock quote: #{last_stock_price[:stock_symbol]} $$$$$$$$$"
      count_failed
      @@logger.error e
    end
  end
  
  def count_failed
    @fail_count ||=0
    @fail_count += 1
  end
  
  def parse_row row
    cells = row.find_all 'td'
    collected_rows = {}
    for i in 0...cells.size 
      name = @@value_indexes[i]
      collected_rows[name] = parse_cell cells[i], name if name
    end
    
    collected_rows
  end
  
  def parse_cell td, name
    value =  clean_html_tags(td)
    if name.to_s.match(/price/)
      Money.parse_bg_money value
    else
      value.gsub(/ /, '')
    end
  end
end