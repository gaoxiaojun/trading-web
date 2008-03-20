require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/scrapping/company_info_parser'

describe CompanyInfoParser do
  STOCK_SYMBOL = 'ADVANC1'
  BULSTAT = 131187474
  
  before(:each) do
    file = File.open File.dirname(__FILE__).to_s + "/info.htm"
    @parser = CompanyInfoParser.new file.readlines.to_s
    @object_for_deletion = []
  end
  
  after(:each) do
    @object_for_deletion.each {|obj| obj.destroy}
  end
  
  it "should extract company name" do
    company_properties =  @parser.exctract_company_info
      
    company_properties[:name].should == 'ADVANCE INVEST'
  end
    
  it "should extract company branch" do
    company_properties =  @parser.exctract_company_info
      
    company_properties[CompanyInfoParser::COMP_BG_BRANCH].should == 'Other financial intermediation n.e.c.'
  end
    
  it "should extract basic company info: city, bulstat, tax#, type, active" do
    company_properties =  @parser.exctract_company_info
      
    company_properties[CompanyInfoParser::COMP_BG_CITY].should == 'Sofia'
    company_properties[:bul_stat].should == '131187474'
    company_properties[CompanyInfoParser::COMP_BG_TAX_NO].should == '1222136438'
    company_properties[:type].should == 'Investment company'
    company_properties[CompanyInfoParser::COMP_BG_ACTIVITY].should == 'Investment in Securities'
  end
    
  it "should extract stock exchange info: code, market, ISIN code, last traded price, last traded date, last 365 days (high, low, average)" do
    company_properties =  @parser.exctract_company_info
    stock_exhange = company_properties[:stock_exchanges][0]
    stock_exhange[:stock_symbol].should == STOCK_SYMBOL
    stock_exhange[:market_name].should == 'Free Market A'
    stock_exhange[:isin_code].should == 'BG1100004040'
    stock_exhange[:last_traded_price].should == Money.bg_money(349)
    stock_exhange[:last_traded_date].should ==  Time.local(2007, 8, 15,0,0,0)
    stock_exhange[:price_high].should == Money.bg_money(370)
    stock_exhange[:price_low].should == Money.bg_money(198)
    stock_exhange[:price_avrg].should == Money.bg_money(272)
  end
    
  it "should extract company financial info: code, market, ISIN code, last traded price, last traded date, last 365 days (high, low, average)" do
    company_properties =  @parser.exctract_company_info
      
    company_properties[CompanyInfoParser::COMP_FIN_CAPITAL].should == Money.bg_money(205000000)
    company_properties[CompanyInfoParser::COMP_FIN_NOMINAL].should == Money.bg_money(100)
    company_properties[CompanyInfoParser::COMP_FIN_PROFIT].should == Money.bg_money(1558700000)
    company_properties[CompanyInfoParser::COMP_FIN_PROFIT_YEAR].should == Date.new(2006, 1, 1)
    company_properties[CompanyInfoParser::COMP_FIN_NET_SALES].should be_nil
    company_properties[CompanyInfoParser::COMP_FIN_NET_SALES_YEAR].should be_nil
    company_properties[CompanyInfoParser::COMP_FIN_FIX_ASSETS].should == Money.bg_money(37627500000)
    company_properties[CompanyInfoParser::COMP_FIN_FIX_ASSETS_YEAR].should == Date.new(2006, 1, 1) 
  end
  
  it "should save company info after parsing if no company with same stock symbol" do
    Company.exists?(:bul_stat => BULSTAT).should be_false
       
    @company_properties =  @parser.exctract_company_info
    @object_for_deletion <<  @parser.store_or_update_company
    
    company = Company.find :first, :conditions => {:bul_stat => BULSTAT}
    
    company.should_not be_nil
    company.company_background.should_not be_nil
    company.company_financial.should_not be_nil
    company.trading_markets.first.should_not be_nil
    
    verify_company_type company
    verify_properties_for company, @company_properties
  end
  
  it "should update only market and financial data for a company after parsing if comapany exists with such bulstat" do
    company = DomainFountain.create_company
    company.bul_stat = BULSTAT
    company.save.should be_true
    current_company_type = company.type
    
    @company_properties =  @parser.exctract_company_info
    
    @object_for_deletion <<  @parser.store_or_update_company
    @object_for_deletion << company
     
    Company.find(:all, :conditions => {:bul_stat => BULSTAT}).size.should == 1
    
    company.type.should == current_company_type
  end
  
  it "should parse and store more than one trading markets per company." do
    file = File.open File.dirname(__FILE__).to_s + "/ADVEQ_info.htm"
    @parser = CompanyInfoParser.new file.readlines.to_s
    Company.exists?(:bul_stat => '175028954').should be_false
       
    @company_properties =  @parser.exctract_company_info
    @object_for_deletion <<  @parser.store_or_update_company
    
    company = Company.find :first, :conditions => {:bul_stat => '175028954 '}
    
    company.should_not be_nil
    company.company_background.should_not be_nil
    company.company_financial.should_not be_nil
    company.trading_markets.first.should_not be_nil
    
    @company_properties.delete(:type)
    verify_properties_for company, @company_properties
  end
  
  def verify_company_type company
    /#{company.type.name[0,4]}/i.should match(@company_properties.delete(:type))
  end
  
  def verify_properties_for obj, properties
    properties.each do |key, value|
      if key == :stock_exchanges
        next unless value
        for i in 0...value.size do
          verify_properties_for obj.trading_markets[i], value[i]
        end
      elsif obj.nested_respond_to? key 
        return_value = obj.nested_send(key)
        if return_value
          return_value = Money::ZERO == return_value ? nil : return_value
          return_value.to_s.should == value.to_s
        else
          value.should be_nil
        end
      end
    end
  end
end