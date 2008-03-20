class Statement < ActiveRecord::Base 
  has_many :statement_amounts
  has_enumerated  :type, :class_name => 'StatementType', :foreign_key => 'statement_type_id'
  has_enumerated  :account_regulation_type
  
  validates_presence_of     :type, :account_regulation_type
  validates_associated      :type, :account_regulation_type
  
  def same? props
    props.each do |key, value|
      unless self.__send__(key) == value
        return false
      end
    end
    return true
  end
end
