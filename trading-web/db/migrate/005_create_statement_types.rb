class CreateStatementTypes < ActiveRecord::Migration
  def self.up
    create_table :statement_types, :force => true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :name,          :string,        :null=>false, :limit => 20
    end
    
    add_index :statement_types, [:name], :unique => true
    
    StatementType.enumeration_model_updates_permitted = true
    
    StatementType.create :name => 'Income Statement'
    StatementType.create :name => 'Balance Sheet' 
    StatementType.create :name => 'Cash Flow'
    
    StatementType.enumeration_model_updates_permitted = false
  end
  
  def self.down
    drop_table :statement_types
  end
end