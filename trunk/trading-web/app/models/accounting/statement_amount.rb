class StatementAmount < ActiveRecord::Base 
  has_enumerated  :account_type
  money :amount, :cents => :amount
  
  validates_presence_of     :account_type
  validates_associated      :account_type
end