require File.dirname(__FILE__) + '/../log_util'

module BaseScrappingParser
  EMPTY = ''
  EMPTY_SPACE = ' '
  NA = 'n.a.'

  def self.logger= log
    @@logger =log
  end
 
  attr_reader :soup, :failed
  
  def initialize body
    if body.kind_of? BeautifulSoup
      @soup = body
    else
      @soup = BeautifulSoup.new body
    end
    @failed = false
    @@logger ||= Logger.logger_for_scrap_parser
  end
  
  protected
  def extract_rows
    @@logger.debug 'start extracting rows...'
    
    rows = @soup.find_all 'tr'
    rows ||= []
    
    if rows.empty?
      @@logger.warn 'NO rows for extraction!' 
      return rows
    end
    
    @row_size = rows.size
    @@logger.debug "Rows to be extracted: #{@row_size}"
    rows
  end
  
  def row_size
    @row_size||=0
    (@row_size - 1)/2
  end
  
  def clean_html_tags tag
    value = tag.to_s.gsub(/<.*?>/,EMPTY )
    value.gsub!(/(\&nbsp;)|(\%nbsp)/, EMPTY_SPACE)
    value.strip!
    value
  end
  
  def validates_numericality_of value
    return nil unless value =~ /^[+-]?\d+$/
    value
  end
  
  def persist obj
    saved = obj.save
    if not saved
      fail
      error = obj.errors.inject(" "){|result, e| result + " " + e.to_s}
      error = error.nil? ? error : error.to_s
      @@logger.error "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SAVE ERROR  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< "
      @@logger.error "Can't save #{obj.class} with id=#{obj.id.nil? ? 'nil' : obj.id} | " << error
    end
  end
  
  def fail
    @failed = true
  end
  
  def log_exception row_number=nil
    begin
      yield
    rescue Exception => e
      fail
      @@logger.error "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ERROR  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< "
      @@logger.error e
      @@logger.error 'for row: ' + row_number.to_s if row_number
    end
  end
  
  def reset_soup
    @soup = nil;
  end
end