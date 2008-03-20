class CreateStockQuotes < ActiveRecord::Migration
  def self.up
    create_table :stock_quotes,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :trading_market_id,    :integer,       :null=>false,  :references => :trading_markets
      t.column   :timepoint,            :timestamp,     :null=>false     
      t.column   :volume,               :integer,       :null=>true
      t.column   :price_avrg,           :integer,       :null=>true
      t.column   :price,                :integer,       :null=>false
      t.column   :currency,             :string,        :null=>false,  :limit=>5               
    end
  end

  def self.down
    remove_foreign_key :stock_quotes, :stock_quotes_ibfk_1
    drop_table :stock_quotes
  end
end