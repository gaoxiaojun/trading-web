class CreateCompanyBackground < ActiveRecord::Migration
  def self.up
     create_table :company_backgrounds,  :force =>true, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :company_id,   :integer,       :null=>false,  :references => :companies
      t.column   :city,         :string,        :null=>true     
      t.column   :tax_no,       :bigint,        :null=>true
      t.column   :branch,       :string,        :null=>true             
      t.column   :activity,     :text,          :null=>true             
    end
  end

  def self.down
    remove_foreign_key :company_backgrounds, :company_backgrounds_ibfk_1
    drop_table :company_backgrounds
  end
end
