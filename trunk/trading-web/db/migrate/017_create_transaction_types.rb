class CreateTransactionTypes < ActiveRecord::Migration
  def self.up
    create_table :transaction_types, :force => true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :name,          :string,        :null=>false, :limit => 5
      t.column   :desc,          :string,        :null=>false, :limit => 30
    end
    
    add_index :transaction_types, [:name], :unique => true
    
    TransactionType.enumeration_model_updates_permitted = true

    TransactionType.create :name =>  'Buy',  :desc => 'Buy'
    TransactionType.create :name =>  'Call', :desc => 'Right to Buy (Call Option)' 
    TransactionType.create :name =>  'Put',  :desc => 'Right to Sell (Put Option)'
    
    TransactionType.enumeration_model_updates_permitted = false
  end
  
  def self.down
    drop_table :transaction_types
  end
end