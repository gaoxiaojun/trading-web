require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../domain_fountain'

describe Portfolio do
  
  it "should have many portfolio withholdings" do
    portfolio = Portfolio.build.with_user.adding_portfolio_withholding.and_save!
       
    p_withholding =  portfolio.portfolio_withholdings[0]
    p_withholding.should_not be_nil
    
    portfolio = Portfolio.find portfolio.id
    portfolio.portfolio_withholdings[0].should == p_withholding
  end
    
  it "should belong to a user" do
    portfolio = Portfolio.build.with_user.and_save!
    user = portfolio.user
    user.should_not be_nil
    
    portfolio = Portfolio.find portfolio.id
    portfolio.user.should == user
  end
  
  it "should find existing portfolio by user login" do
    portfolio = Portfolio.build.with_user.and_save!
    user = portfolio.user
    
    user_portfolio = Portfolio.find_by_or_create_for(user.login)
    
    user_portfolio.id.should == portfolio.id
  end
  
  it "should find create portfolio for user if none exist" do
    user = User.build.and_save!
    
    Portfolio.exists?(:user_id => user.id).should be_false
    
    user_portfolio = Portfolio.find_by_or_create_for(user.login)
    
    Portfolio.exists?(:user_id => user.id).should be_true
    user_portfolio.should_not be_nil
    user_portfolio.user.should == user
    user_portfolio.amount.should == Portfolio::DEFAULT_PORTFOLIO_AMOUNT
  end
end