class CreateUsers< ActiveRecord::Migration
  def self.up
    create_table :users ,   :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :login,            :string, :limit => 80
      t.column :cryptpassword,    :string, :limit => 40
      t.column :validkey,         :string, :limit => 40
      t.column :email,            :string, :limit => 100
      t.column :newemail,         :string, :limit => 100
      t.column :ipaddr,           :string, :limit => 200
      t.column :confirmed,        :integer,                 :default => 0
      t.column :domains,          :string, :limit => 100
      t.column :firstname,        :string, :limit => 100
      t.column :lastname,         :string, :limit => 100
    end
  end

  def self.down
    drop_table :users
  end
end
