require 'rubygems'
require 'mechanize'
require 'rubyful_soup'

require File.dirname(__FILE__) + '/../file_util'
require File.dirname(__FILE__) + '/company_info_parser'
require File.dirname(__FILE__) + '/last_traded_price_parser'

class SoupParser < WWW::Mechanize::Page
  attr_reader :soup
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @soup = BeautifulSoup.new(body)
    super(uri, response, body, code)
  end
end

class ScrapperMechanize
  extend FileParser
  
  BSE_URL = "http://beis.bia-bg.com/bseinfo/srchcrit.php"
  BSE_LAST_TRADED_PRICE_URL = "http://beis.bia-bg.com/bseinfo/lasttraded.php"
  OUTPUT_PATH_LAST_TRADED = File.dirname(__FILE__)+"/../../data/last_traded_prices/LastTradedPrice_"
  OUTPUT_PATH_VERIFY_LAST_TRADED = File.dirname(__FILE__)+"/../../public/companies/verify_log/VerifyLastTradedPrice_"
  OUTPUT_PATH_COMPANY = File.dirname(__FILE__)+"/../../data/companies/Company_"
  COMPANY_LINK_NAME = 'Free'
  SEARCH_FORM_NAME = "crits"
  FILE_EXTENSION = '.html'
  @@logger = nil
  
  def self.logger= log
    @@logger =log
    BaseScrappingParser.logger = log
  end
  
  def self.logger
    unless @@logger
      @@logger = Logger.logger_for_scrap_parser
      BaseScrappingParser.logger = @@logger
    end
    @@logger
  end
  
  def self.execute_companies_collect_local
    logger.info "start scrapping company info from local sources ...."
    execute_locally "/../data/companies/" do |file|
      parser = CompanyInfoParser.new file.readlines.to_s
      parser.store_or_update_company
      parser.failed
    end
  end
  
  def self.execute_companies_collect_web stock_symbol = nil
    logger.info "start scrapping company info from bse web site ...."
    stat_map = {}
    elements = [stock_symbol] if stock_symbol
    self.execute elements do |search_page, letter, agent|  
      search_page.links.each do |link|
        log_exception do
          if link.text.strip == COMPANY_LINK_NAME 
            if stat_map[letter].nil?
              stat_map[letter] = {:total_count => 1, :error_count => 0}
            else
              stat_map[letter][:total_count]+=1
            end
            company_page = agent.click(link)
            soup = company_page.soup
            href = link.href
            href = href.gsub(/[^0-9]/,'')
            logger.info "\n@@@@@ Currently processing: #{letter+href}"
            parser = nil
            exc_thrown = log_exception do
              parser = CompanyInfoParser.new soup
              parser.store_or_update_company
            end
            agent.back
            archive_file(soup, OUTPUT_PATH_COMPANY + today + letter + href) unless parser.no_rows?
            if exc_thrown or parser.failed
              stat_map[letter][:error_count]+=1
            end
          end
        end
      end
    end
    log_statistic stat_map
  end
  
  
  def self.execute_last_traded_price_local
    logger.info "start scrapping last traded price info from local sources ...."
    execute_locally "/../data/last_traded_prices/" do |file|
      parser = LastTradedPriceParser.new file.readlines.to_s
      parser.store_last_traded_prices
      parser.failed
    end
  end
  
  def self.execute_last_traded_price_web
    log_exception do
      agent = WWW::Mechanize.new
      agent.pluggable_parser.html = SoupParser
      soup = agent.get(BSE_LAST_TRADED_PRICE_URL).soup
      parser = LastTradedPriceParser.new soup
      begin
        parser.store_last_traded_prices
      rescue 
      end
      
      date_str = parser.trading_date.strftime("%Y_%m_%d")
      archive_file soup, OUTPUT_PATH_LAST_TRADED + date_str
      added = archive_file parser.verify_last_traded_prices, OUTPUT_PATH_VERIFY_LAST_TRADED + date_str, ".txt"
      if added 
        file = File.open(OUTPUT_PATH_VERIFY_LAST_TRADED+"Links.html", File::WRONLY|File::APPEND|File::CREAT, 0666) 
        file.puts "<a href='/companies/verify_log/VerifyLastTradedPrice_#{date_str}.txt'>VerifyLastTradedPrice_#{date_str}</a><br/>"
      end
    end
  end
  
  def self.execute elements = nil 
    agent = WWW::Mechanize.new
    agent.pluggable_parser.html = SoupParser
    page = agent.get(BSE_URL)
    all_matches = elements ? "" : "*"
    elements = 'A'..'Z' unless elements
    for letter in elements do
      log_exception do
        unless letter.nil? or letter == ""
          logger.info "\n\n################### CURRENT LETTER: #{letter} #########################"
          search_form = page.forms.with.name(SEARCH_FORM_NAME).first
   
          search_form.srchcode= letter
          search_form.crittext= "BSE Code is like: #{letter}#{all_matches}; "
          search_results = agent.submit(search_form, search_form.buttons.first)
      
          yield(search_results, letter, agent)
        end
        agent.back
      end
    end
  end
  
 
  
  def self.log_statistic recorde_stats
    logger.info "\n\n &&&&&&&&&&&&&&&&&&&&&&&&&& Company scrapping has finished. Results: &&&&&&&&&&&&&&&&&&&&&&&&"
    total_count = 0
    error_count = 0
    recorde_stats.each do |key, value|
      total_count +=value[:total_count]
      error_count +=value[:error_count]
      logger.info "LETER: #{key} | TOTAL: #{value[:total_count]} | ERRORS: #{value[:error_count]} "
    end
    
    logger.info "\n--------------------------------------------------------------------------------"
    logger.info "TOTAL COMPANIES: #{total_count} | ERRORS: #{error_count}"
  end

  def self.archive_file html, file_name, file_extension = FILE_EXTENSION
    log_exception do 
      return false if File.exist? file_name + file_extension
      logger.error "******************* Storing a html file: #{file_name} during scrapping *****************"
      File.open(file_name + file_extension, File::CREAT|File::RDWR, 0644) do |f|
        f.puts html
      end
      return true
    end
  end
  
  def self.today
    Time.new.strftime("%Y_%m_%d")  
  end
end  
  