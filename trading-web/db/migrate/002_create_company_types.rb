class CreateCompanyTypes < ActiveRecord::Migration
  def self.up
    create_table :company_types, :force => true, :row_version => false, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column   :name,          :string,        :null=>false, :limit => 20
    end
    
    add_index :company_types, [:name], :unique => true
    
    CompanyType.enumeration_model_updates_permitted = true
    
    CompanyType.create :name => 'BANKING' 
    CompanyType.create :name => 'INDUSTRY'
    CompanyType.create :name => 'INVESTMENT'
    CompanyType.create :name => 'CONSTRUCTION'
    CompanyType.create :name => 'TOURISM'
    CompanyType.create :name => 'REAL ESTATE'
    CompanyType.create :name => 'TRANSPORT'
    CompanyType.create :name => 'TECHNOLOGIES'
    CompanyType.create :name => 'UNSPECIFIED'
    
    CompanyType.enumeration_model_updates_permitted = false
  end
  
  def self.down
    drop_table :company_types
  end
end
