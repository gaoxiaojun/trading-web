require 'money'
DOT = "."
class Money
  CENTS_MULTIPLIER = 100.00
  BGN_CURRENCY = 'BGN'
  EMPTY = ''
  def initialize(cents, currency = BGN_CURRENCY)
    cents = ZERO.cents if cents.nil?
    if cents.kind_of? String 
      cents = cents.gsub(/( )|(\,)/, EMPTY)
      converted_cents = cents.to_f
      converted_cents *= CENTS_MULTIPLIER
      @cents = converted_cents.round
    else
      @cents = cents.round
    end
    @currency = currency
  end
  
  def to_html
    formatted = "<span class=\"#{'red' if negative?}\">" 
    formatted << sprintf("%.2f", cents.to_f / 100  )            
    formatted << "</span>"
  end
  
  
  def html_align
    "right"
  end
  
  def self.parse_bg_money value
    currency = value[value.size - 3, value.size]
    amount = value[0, value.size - 4].gsub(/ /, EMPTY)
    Money.new(amount, currency)
  end
  
  def self.bg_money amount
    Money.new amount, BGN_CURRENCY
  end
  
  def amount
    @cents.to_f / 100
  end
  
  def positive?
    @cents > 0
  end
  
  def negative?
    @cents < 0
  end
  
  def change_sign
    @cents = @cents*-1
  end
  
  ZERO = Money.new(0)
  
  def == other
    return false unless other.is_a? self.class
    self.eql? other
  end
  
  def eql?(other_money)
    cents == other_money.cents && (currency == other_money.currency || cents == 0.0)
  end
end

class MoneyPerTime < Money 
  def initialize amount, unit_of_time
    super(amount)
    @unit_of_time = unit_of_time
  end
  
  def convert_to(unit_of_time)
    unit_of_time.apply_factor @unit_of_time, cents
  end
end

class Date
  def self.parse_euro_date value
    values = value.split DOT
    Date.new values[2].to_i, values[1].to_i, values[0].to_i
  end
  
  def self.parse_param_date value
    values = value.split '-'
    Date.new values[0].to_i, values[1].to_i, values[2].to_i
  end
  def self.convert_year_to_date year
    Date.new year.to_i, 1, 1 if year
  end
  
  def to_html
    strftime '%m/%d/%Y'
  end
  
  def html_align
    "right"
  end
end

class Boolean
  def self.parse boolean
    return true if /True/i.match boolean
    return false
  end
end


#  Float Hacks:
#  1. to_s override.
#	I really hate using sprintf, mainly because i always have to go online
#	and look up the syntax.  I figured i could make that a little easier.
#	Now you can print floats with different precision as easily as:
#		
#	4.123456.to_s(1)	# => "4.1"
#	4.123456.to_s(3)	# => "4.12"
#	4.123456.to_s(3)	# => "4.123"
#	4.123456.to_s(4)	# => "4.1235" (Note the auto rounding from 4.123456)
#	4.123456.to_s			# => "4.123456"


class Float
  alias_method :orig_to_s, :to_s
  def to_s(arg = nil)
    if arg.nil?
      orig_to_s
    else
      sprintf("%.#{arg}f", self)
    end
  end
end


class Object 
  def nested_respond_to? nested_symbols, include_private=false
    properties = nested_symbols.to_s.split DOT
    size = properties.size
    return self.respond_to?(nested_symbols) if size == 1
    
    properties.inject self do |o, nested_symbol| 
      return false if not o
      return false unless o.respond_to? nested_symbol, include_private
      size-=1
      return true if size == 0
      o.send nested_symbol
    end
    
    return true;
  end
  
  def nested_send nested_symbols, args=nil
    properties = nested_symbols.to_s.split DOT
    index = properties.size
    if(index == 1)
      if args
        return self.send(nested_symbols, args)
      else 
        return self.send(nested_symbols)
      end
    end
    
    properties.inject(self) do |o, nested_symbol| 
      index -=1
      if index==0 
        if args
          return o.send(nested_symbol, args)
        else 
          return o.send(nested_symbol)
        end
      else 
        o.send nested_symbol
      end
    end
  end
end

module CollectiveIdea
  module Acts
    module Money
      
      module ClassMethods
        def moneys *properties
          properties.each{|symbol| money symbol,  :cents => symbol }
          class_eval %(class << self; def money_prop; #{properties.inspect} end end)
          class_eval do
            before_validation :check_money_for_not_nil
            def check_money_for_not_nil
              self.class.money_prop.each do |symbol|
                value =  self.send symbol
                self.[]= symbol, 0 if value.nil? or (value.respond_to?(:cents) and value.cents == 0)
              end
            end
          end
        end
        
      end
    end
  end
end


module ActiveRecord
  class Errors
    def remove attribute_name
      @errors.delete attribute_name.to_s
    end
  end
end
