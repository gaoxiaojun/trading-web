require File.dirname(__FILE__) + '/../test_helper'
require 'companies_controller'

# Re-raise errors caught by the controller.
class CompaniesController; def rescue_action(e) raise e end; end

class CompaniesControllerTest < Test::Unit::TestCase
  fixtures :companies

	NEW_COMPANY = {}	# e.g. {:name => 'Test Company', :description => 'Dummy'}
	REDIRECT_TO_MAIN = {:action => 'list'} # put hash or string redirection that you normally expect

	def setup
		@controller = CompaniesController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
		# Retrieve fixtures via their name
		# @first = companies(:first)
		@first = Company.find_first
	end

  def test_component
    get :component
    assert_response :success
    assert_template 'companies/component'
    companies = check_attrs(%w(companies))
    assert_equal Company.find(:all).length, companies.length, "Incorrect number of companies shown"
  end

  def test_component_update
    get :component_update
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_component_update_xhr
    xhr :get, :component_update
    assert_response :success
    assert_template 'companies/component'
    companies = check_attrs(%w(companies))
    assert_equal Company.find(:all).length, companies.length, "Incorrect number of companies shown"
  end

  def test_create
  	company_count = Company.find(:all).length
    post :create, {:company => NEW_COMPANY}
    company, successful = check_attrs(%w(company successful))
    assert successful, "Should be successful"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
    assert_equal company_count + 1, Company.find(:all).length, "Expected an additional Company"
  end

  def test_create_xhr
  	company_count = Company.find(:all).length
    xhr :post, :create, {:company => NEW_COMPANY}
    company, successful = check_attrs(%w(company successful))
    assert successful, "Should be successful"
    assert_response :success
    assert_template 'create.rjs'
    assert_equal company_count + 1, Company.find(:all).length, "Expected an additional Company"
  end

  def test_update
  	company_count = Company.find(:all).length
    post :update, {:id => @first.id, :company => @first.attributes.merge(NEW_COMPANY)}
    company, successful = check_attrs(%w(company successful))
    assert successful, "Should be successful"
    company.reload
   	NEW_COMPANY.each do |attr_name|
      assert_equal NEW_COMPANY[attr_name], company.attributes[attr_name], "@company.#{attr_name.to_s} incorrect"
    end
    assert_equal company_count, Company.find(:all).length, "Number of Companys should be the same"
    assert_response :redirect
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_update_xhr
  	company_count = Company.find(:all).length
    xhr :post, :update, {:id => @first.id, :company => @first.attributes.merge(NEW_COMPANY)}
    company, successful = check_attrs(%w(company successful))
    assert successful, "Should be successful"
    company.reload
   	NEW_COMPANY.each do |attr_name|
      assert_equal NEW_COMPANY[attr_name], company.attributes[attr_name], "@company.#{attr_name.to_s} incorrect"
    end
    assert_equal company_count, Company.find(:all).length, "Number of Companys should be the same"
    assert_response :success
    assert_template 'update.rjs'
  end

  def test_destroy
  	company_count = Company.find(:all).length
    post :destroy, {:id => @first.id}
    assert_response :redirect
    assert_equal company_count - 1, Company.find(:all).length, "Number of Companys should be one less"
    assert_redirected_to REDIRECT_TO_MAIN
  end

  def test_destroy_xhr
  	company_count = Company.find(:all).length
    xhr :post, :destroy, {:id => @first.id}
    assert_response :success
    assert_equal company_count - 1, Company.find(:all).length, "Number of Companys should be one less"
    assert_template 'destroy.rjs'
  end

protected
	# Could be put in a Helper library and included at top of test class
  def check_attrs(attr_list)
    attrs = []
    attr_list.each do |attr_sym|
      attr = assigns(attr_sym.to_sym)
      assert_not_nil attr,       "Attribute @#{attr_sym} should not be nil"
      assert !attr.new_record?,  "Should have saved the @#{attr_sym} obj" if attr.class == ActiveRecord
      attrs << attr
    end
    attrs.length > 1 ? attrs : attrs[0]
  end
end
