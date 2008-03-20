class CreatePortfolios < ActiveRecord::Migration
  def self.up
    create_table :portfolios,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :user_id,              :integer,       :null=>false,  :references => :users
      t.column   :amount,               :integer,       :null=>false,  :default => 0
      t.column   :currency,             :string,        :null=>false,  :default => 'BGN', :limit=>5      
    end
  end

  def self.down
    remove_foreign_key :portfolios, :portfolios_ibfk_1
    drop_table :portfolios
  end
end