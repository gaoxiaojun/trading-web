#require File.join(File.dirname(__FILE__),"../../","config", "environment")
require File.join(File.dirname(__FILE__),"/../log_util")
require File.dirname(__FILE__) + '/../file_util'

class ConvertCompanyStatements
  extend FileParser
  
  @@logger = Logger.logger_for_data_conversion
  
  DIVIDER = "|"
  
  def self.logger
    @@logger
  end
  
  def self.load_financial_statements
    @@logger.info "start loading company financials from local sources ...."
    execute_locally "/../data/financials/", "txt" do |file|
      populate file 
    end
  end
  
  def self.populate file
    unless file.kind_of?(File)
      file = File.open(file.to_s, "r")
    end
     
    @@logger.info "Populating company statement amounts from file ..."

    failed_count = 0;
    all_count = 0;
    statement = nil
      
    file.each do |line|
      print '.'
      all_count+=1
      values = line.split(DIVIDER) 
      created_at = Time.parse values[0]
      stock_symbol = values[1]
      reg_year = values[2]
      reg_qtr = values[3]
      acc_code = AccountType.trasnform_bank_account_number values[4]
      amount = Money.bg_money(values[5].to_i*100)
      consolidated = Boolean.parse values[6]
      audited =  Boolean.parse values[7]
   
      
      account_type = AccountType. find :first, :conditions => {:account_number => acc_code}
      unless account_type
        @@logger.warn "***** No Account Type found for account code: #{acc_code} *****" 
        failed_count+=1
        next
      end
    
      acc_reg_type = account_type.extract_acc_reg_type_from_acc_num
      unless acc_reg_type
        @@logger.warn "^^^^^^ No Account Regulation Type found for for account code: #{acc_code} ^^^^^^^" 
        failed_count+=1
        next
      end
    
      statement_type = account_type.extract_statement_type_from_acc_num
      unless statement_type
        @@logger.warn "^^^^^^ No Statement Type found for for account code: #{acc_code} ^^^^^^^" 
        failed_count+=1
        next
      end
    
      market = TradingMarket.find :first,:conditions => { :stock_symbol => stock_symbol }
      unless market
        @@logger.warn "~~~~~~ No Market found for stock_symbol: #{stock_symbol} ~~~~~~~" 
        failed_count+=1
        next
      end
    
      reg_date = UnitOfTime.conv_qtr_to_date reg_year.to_i, reg_qtr.to_i
      unless reg_date
        @@logger.warn "~~~~~~ Regulatory Date is missing or can't be calculated for reg year #{reg_year} and reg qtr #{reg_qtr} ~~~~~~~"
        failed_count+=1      
        next
      end
    
      props = {:company_id => market.company_id, :statement_type_id => statement_type.id, 
        :account_regulation_type_id => acc_reg_type.id, :regulatory_date => reg_date
      }
    
      if statement.nil? or not statement.same?(props)
        statement = Statement.find :first, :conditions => props
        if statement
          @@logger.info "------------- statement already populated for date: #{created_at} -----------------"
          return true
        end
        
        statement ||= Statement.new props
      
        statement.created_at= created_at  if not statement.created_at
        statement.consolidated= consolidated
        statement.audited= audited
        statement.save
      
        unless statement.valid?
          failed_count+=1  
          @@logger.warn "Can't save statement with given properties: " + statement.inspec
          next unless statement.id
        end
      end
    
      statement_amount = StatementAmount.create :amount => amount, :created_at => created_at,
        :statement_id => statement.id, :account_type_id => account_type.id
      unless statement_amount.valid?
        failed_count+=1  
        @@logger.warn "Can't save statement amount with given properties: " + statement_amount.inspec
        next
      end   
    
    end

    if  failed_count == 0   
      @@logger.info "\nCompany statement amounts populated (#{all_count}) records successfully."
      return false
    else 
      @@logger.error ">>>> There were (#{failed_count}) out of (#{all_count}) during Account Types population!!! <<<<<<<<"
      return true
    end
  end  
end