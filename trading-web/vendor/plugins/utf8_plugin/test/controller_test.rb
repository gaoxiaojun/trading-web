$:.unshift File.dirname(__FILE__) + '/../lib'

$KCODE = 'u'

require 'rubygems' rescue nil
require 'test/unit'
require 'active_support'
require 'action_controller'
require 'init'

class TestController < ActionController::Base
  attr_accessor :headers
end

class ControllerTest < Test::Unit::TestCase
  FORMS = [:kc, :c, :d, :kd]
  
  def setup
    TestController.normalize_unicode_params :form => :kc
    @controller = TestController.new
    
    @forms = (FORMS + [nil]).dup
    @params = {
      :in => { :argument => 'ﬃ' },
      :kc => { :argument => "ffi"},
      :c => { :argument => 'ﬃ' },
      :d => { :argument => 'ﬃ' },
      :kd => { :argument => 'ffi' },
      :empty => '',
      :nil => nil
    }
  end
  
  def test_normalize_unicode_params
    @forms.each do |form|
      assert_nothing_raised { TestController.normalize_unicode_params(:form => form) }
      assert_equal form, TestController.params_normalization_form
    end
    assert_raise(ArgumentError) { TestController.normalize_unicode_params(:form => :unknown) }
  end
  
  def test_run_normalize_params_kcode
    with_kcode('none') do
      @controller.params = @params[:in]
      assert @controller.normalize_params(@controller.class.params_normalization_form)
      assert_equal @params[:in], @controller.params
    end
    with_kcode('UTF8') do
      @controller.params = @params[:in]
      assert @controller.normalize_params(@controller.class.params_normalization_form)
      assert_equal @params[:kc], @controller.params
    end
  end
    
  FORMS.each do |form|
    define_method "test_normalize_strings_in_hash_#{form}" do
      assert_equal @params[form], @controller.normalize_strings_in_hash(@params[:in], form), "In form #{form}"
    end
  end
    
  protected
  
  def with_kcode(kcode)
    $KCODE, old_kcode = kcode, $KCODE
    begin
      yield
    ensure
      $KCODE = old_kcode
    end
  end
end