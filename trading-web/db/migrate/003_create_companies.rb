class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies,    :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :type_id,      :integer,      :null=>false,  :references => :company_types
      t.column   :name,         :string,       :null=>false,  :limit=>160    
      t.column   :bul_stat,     :integer,      :null=>false                  
      t.column   :stock_symbol, :string,       :null=>true,   :limit=>8                  
    end
    
    add_index :companies, [:name],     :unique => true
    add_index :companies, [:bul_stat], :unique => true
  end
  
  def self.down
    remove_foreign_key :companies, :companies_ibfk_1
    drop_table :companies
  end
end
