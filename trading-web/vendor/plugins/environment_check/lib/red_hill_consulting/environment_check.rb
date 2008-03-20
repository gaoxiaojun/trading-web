module RedHillConsulting
  module EnvironmentCheck
    module Base
      def self.included(base)
        base.class_eval do
#          before_filter { |controller| raise "Incorrect database '#{SystemSetting[:environment]}'; expected '#{RAILS_ENV}'" unless SystemSetting[:environment].value == RAILS_ENV }
        end
      end
    end
  end
end