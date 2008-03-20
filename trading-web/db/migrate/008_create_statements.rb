class CreateStatements < ActiveRecord::Migration
  def self.up
    create_table :statements,                 :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :company_id,                 :integer,      :null=>false,  :references => :companies
      t.column   :statement_type_id,          :integer,      :null=>false,  :references => :statement_types
      t.column   :account_regulation_type_id, :integer,      :null=>false,  :references => :account_regulation_types
      t.column   :regulatory_date,            :date,         :null=>false
      t.column   :consolidated,               :boolean,      :null=>false 
      t.column   :audited,                    :boolean,      :null=>false                  
    end
  end
  
  def self.down
    remove_foreign_key :statements, :statements_ibfk_1
    remove_foreign_key :statements, :statements_ibfk_2
    remove_foreign_key :statements, :statements_ibfk_3
    drop_table :statements
  end
end
