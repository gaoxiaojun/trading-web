require 'set'

class HistoricalStatements
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::WARN
  
  ACC_TYPE_HEADER = AccountType.new :account_number => "0", :bg_desc => "Acc Smetki", :en_desc => "Acc Types"
  
  def initialize statements
    @statements = statements
    @table ={}
    @default_unit_of_time = UnitOfTime::QUATERLY
  end
  
  def historical_statement_table 
    return @table if @statements.nil? or @statements.empty?
    
    @header_column =[]
    @table[ACC_TYPE_HEADER] = @header_column
  
    @statements.each do |s|
      parent_sums = {}
      @initial_accounts = Set.new
      s.statement_amounts.each do |amts|
        @initial_accounts << amts.account_type
        add amts.account_type, amts.amount, parent_sums
      end  
      calculate_totals parent_sums
    
      @@logger.warn "Repeating regulatory dates #{s.regulatory_date} in statemnt => #{s.id}" if @header_column.include? s.regulatory_date 
      @header_column.push s.regulatory_date  
    end
    
    @table.each_value do |row|
      fill_missing_values_for row
    end
    
    @table
  end
  
  def convert_table_to unit_of_time
    historical_statement_table if @table.empty?
    return @table if @table.empty?
    header_column = @table.delete HistoricalStatements::ACC_TYPE_HEADER
    converted_dates = Set.new
    previous_dates_to_converted_dates = {}
    header_column.each do |date|
      converted_date = unit_of_time.convert_date date
      converted_dates << converted_date
      previous_dates_to_converted_dates[date] = converted_date
    end
    
    converted_table = {}
    converted_table[HistoricalStatements::ACC_TYPE_HEADER] = converted_dates.sort
    
    @table.each do |key, values|
      converted_pairs = {}
      for i in 0...values.length
         date = header_column[i]
         money = values[i]
         converted_date = previous_dates_to_converted_dates[date]
         moneys = converted_pairs[converted_date] ||= []
         moneys.push money
      end 
      converted_pairs.each do |date, moneys|
        total = 0.0
        moneys.each do |money|
          total += @default_unit_of_time.convert_to unit_of_time, Float.induced_from(money.cents)
        end
        total = total/Float.induced_from(moneys.length)
        row = converted_table[key] ||= []
        row.push Money.new(total)
      end
    end 
    
    return converted_table
  end
  
  private 
  def fill_missing_values_for row
    while row.size < current_column
      row.push Money::ZERO
    end
  end
  
  def add acc_type, amt, parent_sums
    row = @table[acc_type] ||= []
    fill_missing_values_for row
    if row[current_column].nil? or @initial_accounts.include? acc_type then
      row[current_column] ||= amt
    else
      row[current_column] += amt
    end
    
    parent = acc_type.parent
    return if parent.nil?
    
    if parent_sums[parent].nil? then
      parent_sums[parent] = amt 
    else
      parent_sums[parent] += amt
    end
  end
  
  def calculate_totals parent_sums
    new_parent_sum = {}
    parent_sums.each do |acc_type, amount| 
      add(acc_type, amount, new_parent_sum) unless @initial_accounts.include? acc_type
    end
    
    calculate_totals new_parent_sum unless new_parent_sum.empty?
  end
  
  def current_column
    @header_column.size
  end
  
end