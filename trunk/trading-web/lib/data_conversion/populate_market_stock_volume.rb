require File.join(File.dirname(__FILE__),"/../log_util")

class PopulateMarketStockVolume
  @@logger = Logger.logger_for_data_conversion
  cattr_accessor :securities_file
  DIVIDER = "\t"
  
  self.securities_file = '/../../data/securities/All_issues-ENG.txt'
  
  def self.populate 
    successful = true
    failed_count = 0;
    all_count = 0;
  
    @@logger.info "\nStart populating stocks volume:\n"

    File.open(File.join(File.dirname(__FILE__), self.securities_file), "r") do |file|
      file.each do |line|
        begin
          print '.'
          all_count +=1
          next if all_count < 4
        
          values = line.split(DIVIDER) 
          stock_symbol = values[0].strip
          nominal = clean values[3]
          currency = values[4].strip
          volume = clean values[5]
        
        
          market = TradingMarket.find :first, :conditions => {:stock_symbol => stock_symbol}
          unless market
            successful = false
            @@logger.warn "\nFailed: #{failed_count+=1}.---- No market found for stock symbol: #{stock_symbol}"
            next
          end
          
          market.stock_volume = volume.to_i
          market.nominal = Money.new nominal.to_i*100
          market.nominal_currency = currency
          market.save
          
          unless market.valid?
            successful = false
            @@logger.warn market.errors.inspect
            @@logger.warn "\nFailed: #{failed_count+=1}.  Market with stock symol: #{stock_symbol} not saved successfully!"
          end
        rescue Exception => e
          successful = false
          @@logger.error "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ERROR  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< "
          @@logger.error "\nFailed: #{failed_count+=1}. Error on line #{all_count}: "
          @@logger.error e
        end
      end
    end

    if successful 
      @@logger.info "\nMarket Stock Volumes successfully populated (#{all_count}) records."
      return false
    else 
      @@logger.error ">>>>> There was a problem with populating of (#{failed_count}) out of (#{all_count}) market stock volumes  <<<<<<<<"
      return true
    end
    
  end
  
  private
  def self.clean value
    value.strip.gsub(/\,/, '').gsub(/\"/,'')
  end
end
