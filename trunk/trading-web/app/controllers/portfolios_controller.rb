class PortfoliosController < ApplicationController
  
  before_filter :update_params_filter
  
  def add_portfolio_withholding
    require_auth
    flash[:remote_notice]=nil
    @portfolio = Portfolio.find params[:id]
    attr = params[:withholding]
    attr[:stock_symbol] = params[:search][:term]
    @withholding = PortfolioWithholding.new attr
    @portfolio.portfolio_withholdings << @withholding
    if @withholding.valid?
      flash[:remote_notice] = "Your portfolio was updated successfully! You may continue or <a href='#' onclick='Control.Modal.current.close();' style='color: red; text-decoration: none;'><b>Return &#187;</b></a>" 
      create_new_portfolion_withholding
    end
    render :partial => 'add_portfolio_withholding'
  end
  
  def index
    @portfolios = Portfolio.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @portfolios.to_xml }
    end
  end

  def show
    redirect_to("/404.html") and return unless 'user' == params[:id]
    require_auth
    
    @portfolio = Portfolio.find_by_or_create_for(@user.login)
    create_new_portfolion_withholding
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @portfolio.to_xml }
    end
  end
  
  def edit
    @portfolio = Portfolio.find(params[:id])
  end

  def update
    @portfolio = Portfolio.find(params[:id])

    respond_to do |format|
      if @portfolio.update_attributes(params[:portfolio])
        flash[:notice] = 'Portfolio was successfully updated.'
        format.html { redirect_to portfolio_url(@portfolio) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portfolio.errors.to_xml }
      end
    end
  end
   
  private
  def update_params_filter
    @javascripts = %w[calendar]
  end
  
  def create_new_portfolion_withholding
     @withholding = PortfolioWithholding.new 
  end
end
