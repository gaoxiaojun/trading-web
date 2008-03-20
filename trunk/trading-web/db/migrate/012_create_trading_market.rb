class CreateTradingMarket < ActiveRecord::Migration
  def self.up
     create_table :trading_markets,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :company_id,           :integer,       :null=>false,  :references => :companies
      t.column   :market_name,          :string,        :null=>false,  :limit=>80
      t.column   :stock_symbol,         :string,        :null=>false,  :limit=>8
      t.column   :last_traded_price,    :integer,       :null=>true,  :default=>0
      t.column   :last_traded_date,     :timestamp,     :null=>true
      t.column   :prev_close,           :integer,       :null=>true,  :default=>0
      t.column   :price_high,           :integer,       :null=>true,  :default=>0
      t.column   :price_low,            :integer,       :null=>true,  :default=>0
      t.column   :price_avrg,           :integer,       :null=>true,  :default=>0
      t.column   :price_change,         :integer,       :null=>true,  :default=>0
      t.column   :price_change_percent, :float,         :null=>true,  :default=>0.0
      t.column   :currency,             :string,        :null=>true,   :limit=>5  
      t.column   :stock_volume,         :integer,       :null=>true,  :default =>0  
      t.column   :nominal,              :integer,       :null=>true,  :default =>0   
      t.column   :market_cap,           :bigint,        :null=>true,  :default =>0  
      t.column   :nominal_currency,     :string,        :null=>true,  :default =>'BGN'   
    end
    
    add_index :trading_markets, [:stock_symbol],    :unique => true
  end

 
  def self.down
    remove_foreign_key :trading_markets, :trading_markets_ibfk_1
    drop_table :trading_markets
  end
end
