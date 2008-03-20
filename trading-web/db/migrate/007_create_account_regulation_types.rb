class CreateAccountRegulationTypes < ActiveRecord::Migration
  def self.up
    create_table :account_regulation_types,  :force => true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :name,          :string,        :null=>false, :limit => 20
    end
    
    add_index :account_regulation_types, [:name], :unique => true
    
    AccountRegulationType.enumeration_model_updates_permitted = true
    
    AccountRegulationType.create :name => 'BANKING' 
    AccountRegulationType.create :name => 'INDUSTRY'
    AccountRegulationType.create :name => 'INVESTMENT'
    
    AccountRegulationType.enumeration_model_updates_permitted = false
  end
  
  def self.down
    drop_table :account_regulation_types
  end
end