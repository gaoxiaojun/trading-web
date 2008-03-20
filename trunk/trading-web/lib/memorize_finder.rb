class Module
  def memoized_finder(name, conditions=nil)
    class_eval <<-STR
      def #{name}(reload=false)
        @#{name} = nil if reload
        @#{name} ||= find(:all, :conditions => #{conditions.inspect})
      end
    STR
  end
end
