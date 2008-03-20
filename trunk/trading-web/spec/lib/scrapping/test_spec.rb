require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../domain_fountain'
require File.dirname(__FILE__) + '/../../../lib/scrapping/company_info_parser'

describe "Test" do

  
  before(:each) do
   @object_for_deletion = []
  end
  
  after(:each) do
#    @object_for_deletion.each {|obj| obj.destroy}
  end
  
 
  it "test" do
#   path = File.join(File.dirname(__FILE__), "/../../../tmp/scrap_archive/")
#    Dir.entries(path).each do |file_name|
#      next unless file_name.match(/html/)
#      puts ""
#      puts file_name
#      file = File.open path + file_name
#      parser = CompanyInfoParser.new file.readlines.to_s
#      parser.store_or_update_company
#    end
#    
#    file = File.open path +"Company_2007_10_24_B34594.html"
#    @parser = CompanyInfoParser.new file.readlines.to_s
#   
#    @company_properties =  @parser.exctract_company_info
#    @object_for_deletion <<  @parser.store_or_update_company
    
#    company = Company.find :first, :conditions => {:stock_symbol => 'ADVANC'}
#    
#    company.should_not be_nil
#    company.company_background.should_not be_nil
#    company.company_financial.should_not be_nil
#    company.trading_markets.first.should_not be_nil
    
#    verify_company_type company
#    verify_properties_for company, @company_properties
  end
  
#  it "should update only market and financial data for a company after parsing if comapany exists with such bulstat" do
#    company = DomainFountain.create_company
#    company.bul_stat = BULSTAT
#    company.save.should be_true
#    current_company_type = company.type
#    
#    @company_properties =  @parser.exctract_company_info
#    
#    @object_for_deletion <<  @parser.store_or_update_company
#    @object_for_deletion << company
#     
#    Company.find(:all, :conditions => {:bul_stat => BULSTAT}).size.should == 1
#    
#    company.type.should == current_company_type
#  end
#  
#  it "should parse and store more than one trading markets per company." do
#    file = File.open File.dirname(__FILE__).to_s + "/ADVEQ_info.htm"
#    @parser = CompanyInfoParser.new file.readlines.to_s
#    Company.exists?(:bul_stat => '175028954').should be_false
#       
#    @company_properties =  @parser.exctract_company_info
#    @object_for_deletion <<  @parser.store_or_update_company
#    
#    company = Company.find :first, :conditions => {:bul_stat => '175028954 '}
#    
#    company.should_not be_nil
#    company.company_background.should_not be_nil
#    company.company_financial.should_not be_nil
#    company.trading_markets.first.should_not be_nil
#    
#    @company_properties.delete(:type)
#    verify_properties_for company, @company_properties
#  end
  
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
          return_value.to_s.should == value.to_s
        else
          puts key
          value.should be_nil
        end
      end
    end
  end
end