class AccountType < ActiveRecord::Base
  acts_as_enumerated :on_lookup_failure => :enforce_none, :different_name => :account_number
  has_enumerated  :parent, :class_name => "AccountType", :foreign_key => "parent_id"
  
  def <=>(other)
    return -1 unless self.id
    return 1 unless other.id
    
    compare = 0
    begin
      compare = self.id <=> other.id
    rescue
      compare = -1
    end
    compare
  end
  
  def level
    return 0 if parent.nil?
    parent.level + 1
  end
  
  def extract_acc_reg_type_from_acc_num
    reg_type_id = self.account_number[0,1]
    AccountRegulationType.find(reg_type_id)
  end
  
  
  def extract_statement_type_from_acc_num
    statement_type_code = self.account_number[2,4]
    StatementType.parse statement_type_code
  end
  
  def to_s
    extract_number + ' ' + en_desc
  end
  
  def to_html
    indent_count = level
    indentaion = ""
    while  indent_count > 0 
      indentaion << "&nbsp;&nbsp;&nbsp;"
      indent_count -=1
    end
    indentaion << "<span onclick='toggleChildRows(this);'>&nbsp;&nbsp;&nbsp;&nbsp;</span>" << to_s 
  end
  
  def html_align
    "left"
  end
  
  def self.trasnform_bank_account_number account_number
    account_number =  account_number.gsub(/1-BS-1-1/i, '1-BS-1')
  end
  
  private 
  def extract_number
    num = self.account_number[4,self.account_number.size]
    return '' unless num
    nums = num.split '-'
    num = nums.inject{|sum, x| sum+=x + '.'}
  end
end
