class CreateCompanyFinancial < ActiveRecord::Migration
  def self.up
     create_table :company_financials,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :company_id,           :integer,       :null=>false,  :references => :companies
      t.column   :capital,              :bigint,        :null=>true
      t.column   :nominal,              :integer,       :null=>true
      t.column   :profit,               :bigint,        :null=>true
      t.column   :profit_year,          :date,          :null=>true
      t.column   :net_sales,            :bigint,        :null=>true
      t.column   :net_sales_year,       :date,          :null=>true
      t.column   :fixed_assets,         :bigint,        :null=>true
      t.column   :fixed_assets_year,    :date,          :null=>true
      t.column   :currency,             :string,        :null=>true,  :limit=>5  
    end
  end

 
  def self.down
    remove_foreign_key :company_financials, :company_financials_ibfk_1
    drop_table :company_financials
  end
end
