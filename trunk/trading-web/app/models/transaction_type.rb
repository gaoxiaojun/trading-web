# == Schema Information
# Schema version: 18
#
# Table name: transaction_types
#
#  id   :integer(11)     not null, primary key
#  name :string(5)       not null
#  desc :string(30)      not null
#

class TransactionType < ActiveRecord::Base
  acts_as_enumerated :on_lookup_failure => :enforce_none
  
  def self.select_options 
    find(:all).collect {|transaction| [transaction.desc, transaction.name]}
  end
end
