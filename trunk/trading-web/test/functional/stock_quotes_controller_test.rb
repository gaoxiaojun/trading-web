require File.dirname(__FILE__) + '/../test_helper'
require 'stock_quotes_controller'

# Re-raise errors caught by the controller.
class StockQuotesController; def rescue_action(e) raise e end; end

class StockQuotesControllerTest < Test::Unit::TestCase
  fixtures :stock_quotes

  def setup
    @controller = StockQuotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:stock_quotes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_stock_quote
    old_count = StockQuote.count
    post :create, :stock_quote => { }
    assert_equal old_count+1, StockQuote.count
    
    assert_redirected_to stock_quote_path(assigns(:stock_quote))
  end

  def test_should_show_stock_quote
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_stock_quote
    put :update, :id => 1, :stock_quote => { }
    assert_redirected_to stock_quote_path(assigns(:stock_quote))
  end
  
  def test_should_destroy_stock_quote
    old_count = StockQuote.count
    delete :destroy, :id => 1
    assert_equal old_count-1, StockQuote.count
    
    assert_redirected_to stock_quotes_path
  end
end
