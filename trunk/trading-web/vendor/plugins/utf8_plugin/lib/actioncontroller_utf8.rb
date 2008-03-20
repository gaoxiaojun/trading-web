module ActionController #:nodoc:
  module UTF8 #:nodoc:
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      
      # Normalizes all the string values in the incoming CGI parameters. Files and StringIO object are
      # left alone.
      # * <tt>options</tt>:
      # * <tt>:form</tt>: Either :kc, :c, :kd, :d or nil
      #
      # Example
      #
      #   class AccountController < ActionController::Base
      #     normalize_unicode_params :form => :d
      #   end
      def normalize_unicode_params(options={})
        raise ArgumentError.new("Unknown normalization options #{options.inspect}") unless
          options.keys.reject { |i| i == :form }.empty?
        raise ArgumentError.new("Unknown normalization #{options[:form].inspect}") unless
          ActiveSupport::Multibyte::NORMALIZATIONS_FORMS.include?(options[:form]) or options[:form].nil?
        
        unless self.respond_to?(:params_normalization_form)
          self.class_inheritable_accessor(:params_normalization_form)
          self.before_filter do |controller|
            controller.normalize_params(controller.class.params_normalization_form)
          end
        end
        self.params_normalization_form = options[:form]
      end
    end
    
    module InstanceMethods
      
      # Normalizes all the strings in params. +form+ should be on of the four normalization forms
      # or nil to do nothing. Normally you don't call this method directly, instead it's used through
      # +normalize_unicode_params+.
      #
      #   class AccountController < ActionController::Base
      #     normalize_unicode_params :form => :d
      #   end
      #
      # But you can also call it explicitly from an action.
      #
      #   class AccountController < ActionController::Base
      #     def update
      #       normalize_params :d
      #     end
      #   end
      def normalize_params(form)
        normalize_strings_in_hash(params, form) if $KCODE == 'UTF8' and !form.nil?
        true
      end
      
      # Normalizes <tt>str</tt> if str is an utf-8 encoded string
      def normalize_if_string(str, form)
        if str.is_a?(String) and str.is_utf8?
          str.chars.normalize(form)
        else
          str
        end
      end

      # Normalizes the utf-8 encoded strings in the hash
      def normalize_strings_in_hash(h, form)
        h.each_pair do |k, v|
          if v.is_a?(Hash)
            normalize_strings_in_hash(v, form)
          elsif v.is_a?(Array)
            v.map! { |i| normalize_if_string(i, form) }
          elsif v.is_a?(String)
            v.replace normalize_if_string(v, form)
          end
        end
      end
    end
  end
end