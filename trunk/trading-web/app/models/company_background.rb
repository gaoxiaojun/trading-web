# == Schema Information
# Schema version: 18
#
# Table name: company_backgrounds
#
#  id           :integer(11)     not null, primary key
#  company_id   :integer(11)     not null
#  city         :string(255)     
#  tax_no       :integer(20)     
#  branch       :string(255)     
#  activity     :text            
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(11)     default(0), not null
#

class CompanyBackground  < ActiveRecord::Base
  belongs_to :company
  validates_numericality_of :tax_no, :on => :save, :only_integer => true, :allow_nil => true
end
