# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def not_nil(v)
    v.nil? ? '-' : v
  end
  
  def formatted_time time
    time.nil? ? nil: time.strftime('%m/%d/%Y')
  end
  
  def format_time_param time
    time.nil? ? nil: time.strftime('%Y-%m-%d')
  end
  
  def pr(v)
    v.nil? ? '-' : v
  end
  
  def number_change_html n
    return 0 unless n.respond_to?(:zero?)
    return n if n.zero?
    
    n = extract_float n
    
    if n > 0.00
      "<span class='green'>+#{n.to_s(2)}</span>"
    else
      "<span class='red'>#{n.to_s(2)}</span>"
    end
  end
  
  def number_in_thousands n
    return 0 unless n.respond_to?(:zero?)
    return n if n.zero?
    
    n = extract_float n
    n = n / 1000
    sprintf("%.0f", n) 
  end
  
  def show_percent v, parenthesize=false
    v.to_s.gsub(/\+|\-/, "#{parenthesize ? '(' : ''}%").gsub(/(<\/)/, "#{parenthesize ? ')' : ''}</")
  end
  
  def cache(name = {}, options=nil, &block)
    @controller.cache_erb_fragment(block, name, options)
  end
  
  def extract_float n
    n = n.amount if n.instance_of?(Money)
    n = n.to_f
  end
  
  def print_preview?
     @print_preview
  end
end
