# == Schema Information
# Schema version: 18
#
# Table name: company_financials
#
#  id                :integer(11)     not null, primary key
#  company_id        :integer(11)     not null
#  capital           :integer(20)     
#  nominal           :integer(11)     
#  profit            :integer(20)     
#  profit_year       :date            
#  net_sales         :integer(20)     
#  net_sales_year    :date            
#  fixed_assets      :integer(20)     
#  fixed_assets_year :date            
#  currency          :string(5)       
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  lock_version      :integer(11)     default(0), not null
#

class CompanyFinancial  < ActiveRecord::Base
  belongs_to :company
  moneys :capital, :fixed_assets, :nominal, :profit, :net_sales
end
