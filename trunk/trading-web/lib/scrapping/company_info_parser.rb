require 'rubygems'
require 'rubyful_soup'
require File.dirname(__FILE__) + '/base_scrapping_parser'

class CompanyInfoParser
  include BaseScrappingParser

  COMP_BG = 'company_background.'
  COMP_BG_BRANCH =   COMP_BG + 'branch'
  COMP_BG_ACTIVITY = COMP_BG + 'activity'
  COMP_BG_TAX_NO =   COMP_BG + 'tax_no'
  COMP_BG_CITY =     COMP_BG + 'city'
  
  COMP_FIN = 'company_financial.'
  COMP_FIN_CAPITAL            = COMP_FIN + 'capital'
  COMP_FIN_NOMINAL            = COMP_FIN + 'nominal'
  COMP_FIN_PROFIT             = COMP_FIN + 'profit'
  COMP_FIN_PROFIT_YEAR        = COMP_FIN + 'profit_year'
  COMP_FIN_NET_SALES          = COMP_FIN + 'net_sales'
  COMP_FIN_NET_SALES_YEAR     = COMP_FIN + 'net_sales_year'
  COMP_FIN_FIX_ASSETS         = COMP_FIN + 'fixed_assets'
  COMP_FIN_FIX_ASSETS_YEAR    = COMP_FIN + 'fixed_assets_year'
  
  @@new_company_properties = 
    Set.new [
    :stock_symbol, :type, :name, :bul_stat, 
    COMP_BG_BRANCH, COMP_BG_ACTIVITY, COMP_BG_TAX_NO, COMP_BG_CITY,
    COMP_FIN_NOMINAL,
    :market_name
  ]
    
  def store_or_update_company
    properties = exctract_company_info
    return unless properties
    
    company = Company.find :first, :conditions => {:bul_stat =>properties[:bul_stat] }
    company ||= Company.new
    
    company.company_background = CompanyBackground.new if not company.company_background
    company.company_financial = CompanyFinancial.new if not company.company_financial
      
    type_name = properties.delete :type
    company.type= CompanyType.parse type_name, properties[COMP_BG_BRANCH], properties[:name], properties[COMP_BG_ACTIVITY]

    trading_markets = []
    properties.each do |key, value|
      if key == :stock_exchanges 
        value.each do |market| 
          trading_market = TradingMarket.new :prev_close => 0 #TODO: check why nil can't be saved.
          market.each{|k,v| set_property k, v, trading_market}
          trading_markets << trading_market
        end
      else
        set_property key, value, company
      end
    end
    
    persist company
    persist company.company_financial
    persist company.company_background
    
    #the lines below is limitation of rails. Can save has_many objects if the parent object
    #hasn't been saved first. 
    #http://api.rubyonrails.com/classes/ActiveRecord/Associations/ClassMethods.html : Unsaved objects and associations
    
    trading_markets.each do |market| 
      existing_market = company.trading_markets.find_same_market market
      if existing_market
         existing_market.update_market market
         persist existing_market
         company.init_default_stock_symbol market
      else  
        company.trading_markets<<market  
      end
    end
    
    unless company.valid?
      fail
      @@logger.error ""      
      @@logger.error ">>>>>>> Company with bulstat: #{company.bul_stat} and name: #{company.name} can't be saved! <<<<<"
      @@logger.error company.errors.full_messages
      @@logger.error company.errors.inspect
      @@logger.error '##############################################################################'
      @@logger.error ""
    end
    
    company
  end
  
  def set_property key, value, company
    log_exception 'property_company' do
      return if not value or property_already_set? company, key
      key = key.to_s + '='
      company.nested_send(key, value) if company.nested_respond_to? key
    end
  end
  
  def no_rows?
    @no_rows
  end
  
  def exctract_company_info
    rows = extract_rows 
    if rows.empty?
      @no_rows = true
      return nil
    end
    
    @no_rows = false
    
    company_properties = {}
    company_properties[:stock_exchanges]= []
    
    log_exception 'company' do 
      company_properties[:name]= parse_name(rows[1]).gsub(/(\?)|(SPJSC)|(JSC)|(REIT)|(PF)/, '').strip   
      company_properties[COMP_BG_BRANCH]= parse_branch rows[2]

      #bascic info
      cells = parse_property_from_row rows[5], company_properties
      company_properties[COMP_BG_ACTIVITY] = clean_html_tags cells[4].find('span')

      #stock exchange info
      parse_property_from_row rows[7], company_properties

      #financial info
      parse_properties_from_spans rows[9].find('td').find('table').find_all('span').reverse, company_properties
    end
    
    @@logger.debug "Rows extracted: #{company_properties.size.to_s}"
    company_properties
  end
  
  def to_s
    return super if not soup
    soup.to_s
  end
  
  ################################### private ##################################
  private
  
  def property_already_set? obj, key
    return false if obj.new_record?
    return false unless @@new_company_properties.include? key
    return false unless obj.nested_respond_to? key
    value = obj.nested_send(key)
    return false if value.nil? or Money::ZERO == value

    return true;
  end
  
  def parse_name row
    name = clean_html_tags row
    name = name.split(' - ')[0]
  end
  
  def parse_branch row
    value = clean_html_tags row
    value.gsub!(/Branch: /, '')
    value
  end
  
  def parse_property_from_row row, company_properties
    cells = row.find_all 'td'
    for i in 0...cells.size do
      spans = cells[i].find_all('span')
      next if not spans
      spans.reverse!
      parse_properties_from_spans spans, company_properties
    end
    cells
  end
  
  def parse_properties_from_spans spans, properties
    while not spans.empty?
      log_exception 'values'  do
        value = clean_html_tags spans.pop
        case value
          #basic info:
        when /City:/;           properties[COMP_BG_CITY]      = clean_html_tags spans.pop
        when /BULSTAT:/;        properties[:bul_stat]  = validates_numericality_of clean_html_tags(spans.pop)
        when /Tax No:/;         properties[COMP_BG_TAX_NO]    = validates_numericality_of clean_html_tags(spans.pop)
        when 'REGISTRATIONS';   properties[:type]      = clean_html_tags spans.pop
         
          #stock exchange:
        when /BSE code:/;  
          stock_symbol = value.gsub(/BSE code: /, EMPTY)
          properties[:stock_exchanges]<< {}
          properties[:stock_exchanges].last[:stock_symbol] = stock_symbol
        when /Market:/;         properties[:stock_exchanges].last[:market_name] = clean_html_tags spans.pop
        when /ISIN Code:/;      properties[:stock_exchanges].last[:isin_code]   = clean_html_tags(spans.pop)
        when /Last trade:/
          properties[:stock_exchanges].last[:last_traded_price] = Money.bg_money clean_html_tags(spans.pop).gsub(/Price \(BGN\): /,EMPTY)
          properties[:stock_exchanges].last[:last_traded_date]  = Date.parse_euro_date(clean_html_tags(spans.pop).gsub(/Date: /,EMPTY)).to_time
        when /Last 365 days:/
          properties[:stock_exchanges].last[:price_high] = Money.parse_bg_money clean_html_tags(spans.pop)
          properties[:stock_exchanges].last[:price_low]  = Money.parse_bg_money clean_html_tags(spans.pop).gsub(/\- /,EMPTY)
          properties[:stock_exchanges].last[:price_avrg] = Money.parse_bg_money clean_html_tags(spans.pop).gsub(/\- /,EMPTY)
         
          #financials:
        when /Capital \(BGN\):/;              properties[COMP_FIN_CAPITAL] = Money.bg_money clean_html_tags(spans.pop)
        when /Nominal \(BGN\):/;              
          properties[COMP_FIN_NOMINAL ] = Money.bg_money clean_html_tags(spans.pop)
        when /Profit \(thous\. BGN\):/;       properties[COMP_FIN_PROFIT], properties[COMP_FIN_PROFIT_YEAR] = parse_amount_and_year clean_html_tags(spans.pop)
        when /Net Sales \(thous\. BGN\):/;    properties[COMP_FIN_NET_SALES], properties[COMP_FIN_NET_SALES_YEAR] = parse_amount_and_year clean_html_tags(spans.pop)
        when /Fixed Assets \(thous\. BGN\):/; properties[COMP_FIN_FIX_ASSETS], properties[COMP_FIN_FIX_ASSETS_YEAR] = parse_amount_and_year clean_html_tags(spans.pop)
        end
      end
    end
  end
  
  def parse_amount_and_year amount_and_year_token
    return if /'n.a.'/.match(amount_and_year_token)

    year = amount_and_year_token.slice(/\(\d{4}\)/)

    amount = amount_and_year_token.gsub(year ? year : EMPTY, EMPTY).strip! 
    year = year.gsub(/(\()|(\))/, EMPTY).to_i if year
    amount = Money.bg_money(amount)*1000 if amount
    return amount, Date.convert_year_to_date(year)
  end
end