require File.dirname(__FILE__) + '/../../spec_helper'

describe "Account Type" do

  it "should have account_number, parent, bg and eng descriptions" do
    account_paragraph =   AccountType.find(4)
    account_paragraph.should_not be_nil
    account_paragraph.parent.should_not be_nil
    account_paragraph.account_number.should_not be_nil
    account_paragraph.bg_desc.should_not be_nil
    account_paragraph.en_desc.should_not be_nil
  end
  
  it "should have at least two parents in the hierarchy" do
    account_paragraph =   AccountType.find 4
    account_paragraph.parent.parent.should_not be_nil
    account_paragraph.level.should == 2
  end
  
  it "should not have parent if base account number" do
    account_chapter = AccountType.find 1
    account_chapter.parent.should be_nil
  end  
  
  it "should be the same if the parent objects of two children in the same hierarchy " do
    account_paragraph1 =   AccountType.find 4
    account_paragraph2 =   AccountType.find 5
   
    account_paragraph1.parent.should == account_paragraph2.parent
    
    account_paragraph1.parent.should == account_paragraph2.parent
  end
  
  it "should return 0 for hierarchy level when no parent." do
    acc_type = AccountType.find 1
    
    acc_type.level.should == 0
  end
  
  it "should return one more for hierarchy level than its parent" do
    acc_type = AccountType.find 4
    
    parent_level =  acc_type.parent.level
    acc_type.level.should == parent_level+1
  end
  
  it "should extract the Account Regulation Type associated with this account from the account number" do
     acc_type_associated_with_banking = AccountType.new :account_number => '1-BS-2-3-4-5'
     acc_type_associated_with_banking.extract_acc_reg_type_from_acc_num.should == AccountRegulationType[:BANKING]
  end
  
  it "should extract the Statment Type associated with this account from the account number" do
     acc_type_with_balance_sheet = AccountType.new :account_number => '1-BS-2-3-4-5'
     acc_type_with_balance_sheet.extract_statement_type_from_acc_num.should == StatementType['Balance Sheet']
  end
end
