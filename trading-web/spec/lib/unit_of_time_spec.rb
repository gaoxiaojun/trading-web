require File.dirname(__FILE__) + '/../spec_helper'

describe "Unit of Time provides enumeration functionality for different time periods. Possible values (ANNUALIZED, QUOTERLY, MONTHLY, WEEKLY and DAILY) " do

  it "should initialze Unit of Time object with name and key" do
    UnitOfTime.new(5, "Annualized", 365).should_not be_nil
    UnitOfTime::ANNUALIZED.should_not be_nil
  end
  
  it "should be equal based on key" do
    UnitOfTime::ANNUALIZED.should == UnitOfTime.new(5, "Annualized", 365)
  end 
  
  it "should apply factor of 1 when both compare to be the same" do
       UnitOfTime::WEEKLY.convert_to(UnitOfTime::WEEKLY).should == 1.0
  end 
  
  it "should apply factor greater than 1 when previous is smaller unit of time" do
       UnitOfTime::DAILY.convert_to(UnitOfTime::WEEKLY).should == 7.0
       UnitOfTime::DAILY.convert_to(UnitOfTime::WEEKLY, 5).should == 35.0
       UnitOfTime::WEEKLY.convert_to(UnitOfTime::MONTHLY, 5).round.should == 21
#       UnitOfTime::DAILY.convert_to(UnitOfTime::MONTHLY, 2.22).should eql(66.6)
  end 
  
  it "should apply factor less than 1 when previous is smaller unit of time" do
      UnitOfTime::WEEKLY.convert_to(UnitOfTime::DAILY, 14).should == 2.0
#      UnitOfTime::MONTHLY.convert_to(UnitOfTime::DAILY, 14).should eql(0.466666666666667)
#      UnitOfTime::MONTHLY.convert_to(UnitOfTime::WEEKLY, 14).should eql(2.0)
  end 
  
  it "should apply montly factor when both are multiple of month" do
    UnitOfTime::MONTHLY.convert_to(UnitOfTime::ANNUALIZED, 10).should == 120.0
    UnitOfTime::MONTHLY.convert_to(UnitOfTime::QUATERLY, 10).should == 30.0
    UnitOfTime::QUATERLY.convert_to(UnitOfTime::ANNUALIZED, 10).should == 40.0
    
    UnitOfTime::QUATERLY.convert_to(UnitOfTime::MONTHLY, 30).should == 10.0
    UnitOfTime::ANNUALIZED.convert_to(UnitOfTime::MONTHLY, 120).should == 10.0
    UnitOfTime::ANNUALIZED.convert_to(UnitOfTime::QUATERLY, 40).should == 10.0
  end
 
  it "should be multiply monthly when Monthly or greater" do
    UnitOfTime::MONTHLY.should be_monthly_multiplier
    UnitOfTime::QUATERLY.should be_monthly_multiplier
    UnitOfTime::ANNUALIZED.should be_monthly_multiplier
       
    UnitOfTime::WEEKLY.should_not be_monthly_multiplier
    UnitOfTime::DAILY.should_not be_monthly_multiplier
  end 
  
  it "should convert date when Daily to the same date" do
    date = Date.new 2007, 7, 30
    UnitOfTime::DAILY.convert_date(date).should == date
  end
  
  it "should convert date when Weekly to the Monday of the week of the given date" do
    monday = Date.new 2007, 7, 23
    UnitOfTime::WEEKLY.convert_date(monday).should == monday
    
    thursday = Date.new 2007, 7, 26
    UnitOfTime::WEEKLY.convert_date(thursday).should == monday
  end
  
  it "should convert date when Weekly to the first of month if Monday sleeps in previous month " do
    thursday_in_aug  = Date.new 2007, 8, 2
    wed_first_of_aug = Date.new 2007, 8, 1 
    
    UnitOfTime::WEEKLY.convert_date(thursday_in_aug).should == wed_first_of_aug
  end
  
  it "should convert date to the first of month when Monthly" do
    thursday_in_aug  = Date.new 2007, 8, 2
    wed_first_of_aug = Date.new 2007, 8, 1 
    
    UnitOfTime::MONTHLY.convert_date(thursday_in_aug).should == wed_first_of_aug
  end
  
  it "should convert date to the first of Jan when Quaterly and date is within first quater (Jan, Feb, March)" do
    first_of_Jan = Date.new 2007, 1, 1 
    
    jan  = Date.new 2007, 1, 15
    UnitOfTime::QUATERLY.convert_date(jan).should == first_of_Jan
    
    feb  = Date.new 2007, 2, 15
    UnitOfTime::QUATERLY.convert_date(feb).should == first_of_Jan
    
    march  = Date.new 2007, 3, 15
    UnitOfTime::QUATERLY.convert_date(march).should == first_of_Jan
  end
  
  it "should convert date to the first of April when Quaterly and date is within second quater (Apr, May, Jun)" do
    first_of_Apr = Date.new 2007, 4, 1 
    
    apr  = Date.new 2007, 4, 15
    UnitOfTime::QUATERLY.convert_date(apr).should == first_of_Apr
    
    may  = Date.new 2007, 5, 15
    UnitOfTime::QUATERLY.convert_date(may).should == first_of_Apr
    
    jun  = Date.new 2007, 6, 15
    UnitOfTime::QUATERLY.convert_date(jun).should == first_of_Apr
  end  
    
  it "should convert date to the first of July when Quaterly and date is within thirth quater (Jul, Aug, Sept)" do
    first_of_Jul = Date.new 2007, 7, 1 
    
    jul  = Date.new 2007, 7, 2
    UnitOfTime::QUATERLY.convert_date(jul).should == first_of_Jul
   
    aug  = Date.new 2007, 8, 2
    UnitOfTime::QUATERLY.convert_date(aug).should == first_of_Jul
    
    sep  = Date.new 2007, 9, 2
    UnitOfTime::QUATERLY.convert_date(sep).should == first_of_Jul
  end 
    
  it "should convert date to the first of October when Quaterly and date is within fourth quater (Oct, Nov, Dec)" do
    first_of_Oct = Date.new 2007, 10, 1 
    
    oct  = Date.new 2007, 10, 2
    UnitOfTime::QUATERLY.convert_date(oct).should == first_of_Oct
   
    nov  = Date.new 2007, 11, 2
    UnitOfTime::QUATERLY.convert_date(nov).should == first_of_Oct
    
    dec  = Date.new 2007, 12, 2
    UnitOfTime::QUATERLY.convert_date(dec).should == first_of_Oct
    
  end
  
  it "should convert date to the first of Jan of the same year when Annualized" do
    jan_1 = Date.new 2007, 1, 1 
    
    jan  = Date.new 2007, 1, 2
    UnitOfTime::ANNUALIZED.convert_date(jan).should == jan_1
   
    june  = Date.new 2007, 6, 2
    UnitOfTime::ANNUALIZED.convert_date(june).should == jan_1
    
    dec  = Date.new 2007, 12, 2
    UnitOfTime::ANNUALIZED.convert_date(dec).should == jan_1
  end
  
  it "should convert quoter number and year to first date of the quoter" do
    UnitOfTime.conv_qtr_to_date(2007, 1).should == Date.new(2007, 1, 1)
    UnitOfTime.conv_qtr_to_date(2007, 2).should == Date.new(2007, 4, 1)
    UnitOfTime.conv_qtr_to_date(2007, 3).should == Date.new(2007, 7, 1)
    UnitOfTime.conv_qtr_to_date(2007, 4).should == Date.new(2007, 10, 1)
    
    UnitOfTime.conv_qtr_to_date(2007, 5).should be_nil
    UnitOfTime.conv_qtr_to_date(2007, 0).should be_nil
  end
end