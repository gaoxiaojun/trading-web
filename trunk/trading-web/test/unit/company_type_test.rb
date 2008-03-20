require File.dirname(__FILE__) + '/../test_helper'
require 'set'

class CompanyTypeTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = false
  self.use_transactional_fixtures = true

  def test_should_retrieve_all_company_types
    assert_equal 3, CompanyType.count
  end

  def test_all_entries_should_be_of_comapny_type_instance
    company_types = CompanyType.find_all
    assert !company_types.empty?

    company_types.each {|company_type| assert_instance_of CompanyType, company_type}
  end

  def test_company_type_enumerated_entry_should_be_with_unique_name
    company_types = CompanyType.find_all
    assert !company_types.empty?

    company_type_names = Set.new
    company_type_names.merge company_types.collect {|company_type| company_type.name}

    assert_equal company_types.size, company_type_names.size
 end
end
