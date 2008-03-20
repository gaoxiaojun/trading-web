class UnitOfTime 
  attr_reader :key, :name, :factor
  
  MONDAY = 1
  
  def initialize key, name, factor
    @key = key
    @name = name
    @factor = factor
  end
  
  ANNUALIZED = UnitOfTime.new 5, "Annualized", 364.0
  QUATERLY   = UnitOfTime.new 4, "Quoterly", 91.0
  MONTHLY    = UnitOfTime.new 3, "Monthly", 30.0
  WEEKLY     = UnitOfTime.new 2, "Weekly", 7.0
  DAILY      = UnitOfTime.new 1, "Daily", 1.0
  
  def convert_to other_unit_of_time, amount = 1
      if other_unit_of_time.monthly_multiplier? and self.monthly_multiplier? 
        other_factor = other_unit_of_time.monthly_factor
        current_factor = self.monthly_factor
      else
        other_factor = other_unit_of_time.factor
        current_factor = self.factor 
      end

      other_factor * amount / current_factor
  end
  
  def monthly_factor
    Float.induced_from((factor/MONTHLY.factor).to_i)
  end
  
  def convert_date date
    case self
      when DAILY 
        date
      when WEEKLY 
        date -= 1 until date.wday == MONDAY or date.mday == 1
      when MONTHLY 
        date -=1 until date.mday == 1
      when QUATERLY
        month = date.month
        month = (month/3 - (month%3==0?1:0))*3 + 1
        date = Date.new date.year, month, 1
      when ANNUALIZED
        date = Date.new date.year, 1, 1
      end
   return date
  end
  
  def monthly_multiplier?
    (MONTHLY <=> self) <  1 
  end
  
  def <=>(other)
    self.factor <=> other.factor
  end
  
  def eql? other
    self == other
  end
  
  def === other
    self == other 
  end
  
  def == other
    return false if other.nil?
    return true if other.equal? self
    return false unless other.instance_of? self.class
    
    self.key == other.key
  end
  
  def self.conv_qtr_to_date qtr_year, qtr
    return nil unless qtr >= 1 and qtr <= 4
    month = qtr + 2*(qtr-1)
    Date.new qtr_year, month, 1
  end
end