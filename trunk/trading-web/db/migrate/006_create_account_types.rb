class CreateAccountTypes < ActiveRecord::Migration
  def self.up
    create_table :account_types, :force =>true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :parent_id,          :integer,      :null=>true,   :references => :account_types
      t.column   :account_number,     :string,       :null=>false,  :limit=>80
      t.column   :bg_desc,            :string,       :null=>false
      t.column   :en_desc,            :string,       :null=>false              
    end
    
    add_index :account_types, [:account_number], :unique => true
    
    AccountType.enumeration_model_updates_permitted = true

    chapter = AccountType.create :account_number => "1-1000", :bg_desc => "I. ACTIVI", :en_desc => "I. Извънредни приходи"
    AccountType.create :parent => chapter, :account_number => "1-1000-1", :bg_desc => "A. Parichni Smetki v Banka i drugi", :en_desc => "A. Money accounts in Banks and others"
    AccountType.create :parent => chapter, :account_number => "1-1000-2", :bg_desc => "B. Vzimanija ot finansovi institucii", :en_desc => "B. Assets from other financial institutions"
    AccountType.create :parent_id => 3, :account_number => "1-1000-2-a", :bg_desc => "1. Bezsrochin depositi v banki", :en_desc => "1. Unlimited bank deposits"
    AccountType.create :parent_id => 3, :account_number => "1-1000-2-b", :bg_desc => "2. Srochni depositi v banki", :en_desc => "2. Limited bank deposits"
    
    AccountType.enumeration_model_updates_permitted = false
  end
  
  def self.down
    remove_foreign_key :account_types, :account_types_ibfk_1
    drop_table :account_types
  end
end