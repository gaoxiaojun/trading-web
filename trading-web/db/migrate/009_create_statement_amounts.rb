class CreateStatementAmounts < ActiveRecord::Migration
  def self.up
    create_table :statement_amounts,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :account_type_id,    :integer,      :null=>false,  :references => :account_types
      t.column   :statement_id,       :integer,      :null=>false,  :references => :statements
      t.column   :amount,             :bigint,       :null=>false
      t.column   :currency,           :string,       :null=>false,  :limit=>5
    end
  end
  
  def self.down
    remove_foreign_key :statement_amounts, :statement_amounts_ibfk_1
    remove_foreign_key :statement_amounts, :statement_amounts_ibfk_2
    drop_table :statement_amounts
  end
end
