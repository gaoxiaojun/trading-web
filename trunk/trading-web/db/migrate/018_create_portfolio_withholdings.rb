class CreatePortfolioWithholdings < ActiveRecord::Migration
  def self.up
    create_table :portfolio_withholdings , :force => true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :portfolio_id,         :integer,  :null=>false,  :references => :portfolios
      t.column :trading_market_id,    :integer,  :null=>false,  :references => :trading_markets
      t.column :transaction_type_id,  :integer,  :null=>false,  :references => :transaction_types
      t.column :shares,               :integer,  :null=>false
      t.column :date,                 :date,     :null=>false
      t.column :price,                :integer,  :null=>true,   :default => 0
      t.column :currency,             :string,   :null=>true,   :default => 'BGN'
      t.column :pitch,                :text,     :null=>true
    end
  end

  def self.down
    remove_foreign_key :portfolio_withholdings, :portfolio_withholdings_ibfk_1
    remove_foreign_key :portfolio_withholdings, :portfolio_withholdings_ibfk_2
    remove_foreign_key :portfolio_withholdings, :portfolio_withholdings_ibfk_3
    drop_table :portfolio_withholdings
  end
end
