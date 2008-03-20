# == Schema Information
# Schema version: 18
#
# Table name: portfolios
#
#  id           :integer(11)     not null, primary key
#  user_id      :integer(11)     not null
#  amount       :integer(11)     default(0), not null
#  currency     :string(5)       default("BGN"), not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(11)     default(0), not null
#

class Portfolio < ActiveRecord::Base
  DEFAULT_PORTFOLIO_AMOUNT = Money.bg_money(5000000)
  has_many   :portfolio_withholdings, :dependent => :destroy  
  moneys :amount
  belongs_to :user 

  def self.find_by_or_create_for user_login
    user_portfolio = Portfolio.find(:first, :conditions => ['user_id = (select u.id from users u where u.login = ?)', user_login])
    return user_portfolio unless user_portfolio.nil?
    user = User.find_by_login(user_login)
    return nil if user.nil?
    create(:amount => DEFAULT_PORTFOLIO_AMOUNT, :user_id => user.id)
  end
  
  def available_amount
    self.amount
  end
end
