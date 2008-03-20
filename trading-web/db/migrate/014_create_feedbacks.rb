class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks ,   :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :email,          :string,  :null=>false,  :limit=>68
      t.column :category,       :string,  :null=>false,  :limit=>50
      t.column :subject,        :string,  :null=>false,  :limit=>256
      t.column :description,    :text,    :null=>false
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
