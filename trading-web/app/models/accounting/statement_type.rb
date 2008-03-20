class StatementType < ActiveRecord::Base
  acts_as_enumerated :on_lookup_failure => :enforce_none
  
  def self.parse statement_type_code
    first_symbol = statement_type_code[0,1]
    StatementType.find(:all).each  do |current_type|
       return current_type if /^#{first_symbol}/i.match(current_type.name)
     end
     
     nil
  end
end
