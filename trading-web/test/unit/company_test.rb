require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = :no_instances
   fixtures :companies, :trading_markets, :statements, :statement_amounts

  def test_should_retrieve_all_companies
    assert_equal 3, Company.count
  end

  def test_should_have_associated_company_type
    himco = companies :himco
    assert_equal 'HIMCO', himco.name

    assert_equal CompanyType[:INVESTMENT], himco.type
  end

  def test_should_not_raise_exception_when_not_valid_company_type_is_associated_with_company
    bulbank = companies :bulbank
    assert_equal 'BUL BANK', bulbank.name
    assert_equal CompanyType[:BANKING], bulbank.type

    assert_nothing_raised do
      bulbank  = CompanyType[:NOT_EXISTING]
    end
  end

  def test_should_associate_succesfully_with_valid_company_type
    pharma = companies :pharma

    assert_not_nil pharma.type
    assert_equal CompanyType[:INDUSTRY], pharma.type

    pharma.type = :BANKING

    assert_not_nil pharma.type
    assert_equal CompanyType[:BANKING], pharma.type
  end

  #VALIDATION
  def test_should_validate_requiring_of_company_name_bul_stat_and_type
    company = Company.new
    assert !company.valid?

    assert company.errors.invalid?(:name)
    assert company.errors.invalid?(:bul_stat)
    assert company.errors.invalid?(:type)
    assert @@ERROR_MESAGE_NOT_UNIQUE, company.errors[:name]
    assert @@ERROR_MESAGE_NOT_UNIQUE, company.errors[:bul_stat]
    assert @@ERROR_MESAGE_NOT_UNIQUE, company.errors[:type]
  end

  def test_should_validate_numericality_of_company_bul_stat
    company = create_valid_company_object
    company.bul_stat = 'something not a number'

    assert !company.valid?

    assert company.errors.invalid?(:bul_stat)
    assert @@ERROR_MESAGE_NOT_NUMBER, company.errors[:bul_stat]
  end

  def test_should_validate_uniqueness_of_company_name_and_bul_stat
    same_company1 = create_valid_company_object
    same_company2 = create_valid_company_object

    same_company1.save
    same_company2.save

    assert !same_company2.valid?

    assert same_company2.errors.invalid?(:name)
    assert same_company2.errors.invalid?(:bul_stat)
    assert @@ERROR_MESAGE_NOT_UNIQUE, same_company2.errors[:name]
    assert @@ERROR_MESAGE_NOT_UNIQUE, same_company2.errors[:bul_stat]
  end

  private
  def create_valid_company_object
    company = Company.new :name =>'Some Name', :bul_stat=>2343, :type_id => CompanyType[:BANKING].id
    assert company.valid?
    company
  end
end
