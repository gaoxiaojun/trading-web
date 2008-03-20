require File.dirname(__FILE__) + '/../../spec_helper'

describe "Statement should build dynamic historical table from statemnt dates and account type amounts." do

  it "should return empty statement table when no statements " do
    HistoricalStatements.new(nil).historical_statement_table.should be_empty
    HistoricalStatements.new([]).historical_statement_table.should be_empty
  end
  
  it "should return statement table with regulatory dates in the header row and account type and corresponding amounts in the other rows" do
    regulatory_dates = [Date.new(2006, 10, 26), Date.new(2007, 10, 26)]
    amounts0 = [[1000, 4], [2000, 5], [3000, 3]]
    amounts1 = [[4000, 4], [5000, 5], [9000, 3]]
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1

    table = HistoricalStatements.new(statements).historical_statement_table
   
    table.size.should == 5
    verify_header_column table, regulatory_dates
    
    amounts0.concat [[3000,1]]
    amounts1.concat [[9000,1]]
    verify_columns table, amounts0.concat(amounts1)
  end
  
  it "statement tabble should disregards repeating account_types in one statement" do
    regulatory_dates = [Date.new(2006, 10, 26), Date.new(2006, 10, 26)]
    amounts0 = [[1000, 4], [2000, 4], [2000, 5], [3000, 3]]
    amounts1 = [[4000, 4], [5000, 5], [9000, 3]]
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1

    table = HistoricalStatements.new(statements).historical_statement_table
    
    table.size.should == 5
    
    verify_header_column table, regulatory_dates
    
    amounts0.delete_at 1
    amounts0.concat [[3000,1]]
    amounts1.concat [[9000,1]]
    verify_columns table, amounts0.concat(amounts1)
  end

  it "statement tabble should account for empty account_types in the last statements" do
    regulatory_dates = [Date.new(2006, 10, 26), Date.new(2007, 10, 26)]
    amounts0 = [[1000, 4], [2000, 5], [3000, 3]]
    amounts1 = [[4000, 4], [9000, 3]]
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1

    table = HistoricalStatements.new(statements).historical_statement_table
    
    table.size.should == 5

    verify_header_column table, regulatory_dates
    
    amounts1.insert 2, [0, 5]
    amounts0.concat [[3000,1]]
    amounts1.concat [[9000,1]]
    verify_columns table, amounts0.concat(amounts1)
  end
 
  it "statement tabble should account for empty account_types before the last statements" do
    regulatory_dates = [Date.new(2006, 10, 26), Date.new(2007, 10, 26), Date.new(2008, 10, 26)]
    amounts0 = [[1000, 4], [3000, 3]]
    amounts1 = [[5000, 5], [9000, 3]]
    amounts2 = [[6000, 4], [7000, 5], [13000, 3]]
    
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1
    statements[2] = create_statement regulatory_dates[2], amounts2

    table = HistoricalStatements.new(statements).historical_statement_table
    
    table.size.should == 5
    
    verify_header_column table, regulatory_dates
    
    amounts0.insert 2, [0, 5]
    amounts1.insert 0, [0, 4]
    amounts0.concat [[3000,1]]
    amounts1.concat [[9000,1]]
    amounts2.concat [[13000,1]]
    verify_columns table, amounts0.concat(amounts1).concat(amounts2)
  end
  
  it "statement tabble should calculate account type totals per account type parrent if one doesn't exist" do
    regulatory_dates = [Date.new(2006, 10, 26), Date.new(2007, 10, 26)]
    amounts0 = [[10, 4], [30, 5],[40,3]]
    amounts1 = [[20, 4], [50, 5],[25,2]]
    
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1

    table = HistoricalStatements.new(statements).historical_statement_table
    
    table.size.should == 6
    
    verify_header_column table, regulatory_dates
    amounts0.concat [[40,1],[0,2]]
    amounts1.concat [[70, 3],[95,1]]
    verify_columns table, amounts0.concat(amounts1)
  end
  
  it "statement tabble should sort all rows based on account number" do
    regulatory_dates = [Date.new(2006, 10, 26)]
    amounts = [[10, 4], [30, 5], [50, 2]]
    statements = [create_statement(regulatory_dates[0], amounts)]
    
    table = HistoricalStatements.new(statements).historical_statement_table
  
    sorted_result = [[HistoricalStatements::ACC_TYPE_HEADER, [regulatory_dates[0]]]]
    sorted_result.push [AccountType.find(1), [Money.new(90)]]
    sorted_result.push [AccountType.find(2), [Money.new(50)]]
    sorted_result.push [AccountType.find(3), [Money.new(40)]]
    sorted_result.push [AccountType.find(4), [Money.new(10)]]
    sorted_result.push [AccountType.find(5), [Money.new(30)]]
    
    table.sort.should == sorted_result
  end
  
  it "statement tabble should calculate anualized statements" do
    regulatory_dates = [Date.new(2006, 2, 26), Date.new(2006, 7, 24)]
    amounts0 = [[10, 4], [30, 5],[40,3]]
    amounts1 = [[20, 4], [50, 5],[25,2]]
    
    statements = []
    statements[0] = create_statement regulatory_dates[0], amounts0
    statements[1] = create_statement regulatory_dates[1], amounts1

    table = HistoricalStatements.new(statements).convert_table_to UnitOfTime::ANNUALIZED
    
    table.size.should == 6
    
    verify_header_column table, [Date.new(2006, 1, 1)]

    amounts = [[270,1],[50,2],[220,3],[60, 4],[160, 5]]
    verify_columns table, amounts
  end
  
  
  private
  def create_statement(regulatory_date, amounts)
    statement_amounts = []
    statement = Statement.new :regulatory_date => regulatory_date
    amounts.each do |amount|
      statement_amounts.push(StatementAmount.new(:amount => Money.new(amount[0]) , :account_type => AccountType.find(amount[1])))
    end
    statement.stub!(:statement_amounts).and_return(statement_amounts)
    statement
  end
  
  def verify_header_column(table, header_dates)
    header_column = table.delete HistoricalStatements::ACC_TYPE_HEADER
    header_column.size.should == header_dates.size
    i = 0
    header_dates.each do |date|
      header_column[i].should == date
      i+=1
    end
  end
  
  def verify_columns(table, expected_values)
    expected_map ={}
    expected_values.each do |value| 
      expected_column = expected_map[value[1]] ||= []
      expected_column.push value[0]
    end
    
    expected_map.each do |key, values|
      acc_type = AccountType.find key
      column = table.delete acc_type
      
      values.each do |value|
        value = Money.new value unless value.nil?
        column.delete_at(0).should == value
      end
      column.should be_empty
    end
    table.should be_empty
  end
end
