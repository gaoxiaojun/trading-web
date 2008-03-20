require File.join(File.dirname(__FILE__),"/../log_util")

class PopulatedAccountTypes 
  @@logger = Logger.logger_for_data_conversion
  cattr_accessor :account_types_file
  DIVIDER = "\t"
  
  self.account_types_file= '/../../data/account_types/account_types'
  
  def self.populate 
    successful = true
    failed_count = 0;
    all_count = 0;
  
    @@logger.info "\nStart populating account types:\n"
    
    AccountType.enumeration_model_updates_permitted = true
    File.open(File.join(File.dirname(__FILE__), account_types_file), "r") do |file|
      file.each do |line|
        print '.'
        all_count +=1
        value,key = line.split(DIVIDER) 
        key = key.strip 
        key = AccountType.trasnform_bank_account_number key
    
        index = key.rindex('-')  
        parent_key = key.slice 0, index
      
        parent = AccountType. find :first, :conditions => {:account_number => parent_key}
        parent_id = parent ? parent.id : nil
      
        chapter = AccountType.create :account_number => key, :bg_desc => value, :en_desc => value, :parent_id => parent_id
   
        unless chapter.valid?
          successful = false
          @@logger.warn chapter.inspect
          @@logger.warn "\nFailed: #{failed_count+=1}.  KEY: #{key}           : VALUE #{value}"
        end
      end
    end

    AccountType.enumeration_model_updates_permitted = true
    if successful 
      @@logger.info "\nAccount Types successfully populated (#{all_count}) records."
      return false
    else 
      @@logger.error ">>>>> There was a problem with populating of (#{failed_count}) out of (#{all_count})account types  <<<<<<<<"
      return true
    end
    
  end
end
