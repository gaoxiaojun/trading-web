class CompaniesController < ApplicationController
  include AjaxScaffold::Controller, CompaniesHelper
  
  after_filter :clear_flashes
  before_filter :update_params_filter
  
  #  caches_action :index, :show
  
  def update_params_filter
    @javascripts = ['ajax_scaff']
    @javascripts.concat ['plotr/graph_combined_c'] if params[:action]=='show'
    update_params :default_scaffold_id => "company", :default_sort => 'last_traded_date', :default_sort_direction => "desc"
  end
  
  def index
  end
  
  def show
    p = params[:id]
    unless p.nil? or p.empty? then
      load_company
      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => @company.to_xml }
      end
    end
  end
  
  def sector
    params[:sector]=params[:id]
    render :template => "companies/index"
  end
  
  def traded_on
    params[:traded_on]=params[:id]
    render :template => "companies/index"
  end
  
  def financials
    cache_block 'company_financials:'+params[:id] do
      load_company
      build_table_for_income_statement
      render :partial => 'financials'
    end
  end
  
  def financials_xls
    load_company
    render :partial => 'financials_xls'
  end
  
  def financials_xls_print_preview
    load_company
    show_in_print_preview
    render :partial => 'financials_xls', :layout => true
  end
  
  def overview
    cache_block 'company_overview:'+params[:id] do
      load_company
      render :partial => 'overview' 
    end
  end
  
  def background
    cache_block 'company_background:'+params[:id] do
      load_company
      render :partial => 'background' 
    end
  end
  
  def statement
    cache_block params[:id] +","+ params[:type] do
      statement_type = load_company_and_build_statement_table 
      render :partial => 'statements', :locals => { :type_id => statement_type.id} 
    end
  end
  
  def annualized
    cache_block params[:id] +","+ params[:type]+",ann" do
      statement_type = load_company_and_build_statement_table UnitOfTime::ANNUALIZED
      render :partial => 'statements', :locals => { :type_id => statement_type.id} 
    end
  end
  
  def print_preview 
    id = params[:id]
    type = params[:type]
    ann = params[:ann]
    unless id.nil? or type.nil? then
      unit_of_time = UnitOfTime::ANNUALIZED if ann
      load_company_and_build_statement_table unit_of_time
      show_in_print_preview
    end
  end
  
  def component_update
    @show_wrapper = false # don't show the outer wrapper elements if we are just updating an existing scaffold 
    if request.xhr?
      component  #if javascript, then update dynamically
    else
      redirect_to :action => 'index'  #if no javascript
    end
  end

  def component  
    @show_wrapper = true if @show_wrapper.nil?
    @sort_sql = Company.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    options = { :order => @sort_sql, :include => :trading_markets,
      :per_page => records_per_page, :conditions => conditions}
    if !@sort_sql.nil? and @sort_sql.match(/(change)/i)
      sort_by_price_change options
    else
      @sort_by = @sort_sql.nil? ? "#{Company.table_name}.#{Company.primary_key} asc" : @sort_sql  + " " << current_sort_direction(params)
      options[:order] = @sort_by
      @paginator, @companies = paginate(:companies, options)
    end
    render :action => "component", :layout => false
  end

  private
  
  def conditions
    id_cond = id_conditions
    cond = " companies.stock_symbol = trading_markets.stock_symbol "
    if id_cond
      if id_cond.is_a? Array
        id_cond[0]= cond << ' AND ' << id_cond[0]
        id_cond
      else
        cond = cond<<' AND ' << id_cond
      end
    else
      cond
    end
  end
  
  def id_conditions
    ids = params[:ids]
    unless ids.nil? or ids.empty?
      return  "companies.id in (#{ids})"
    end
    
    sector = params[:sector]
    return ['companies.type_id = ?', CompanyType[sector.upcase].id] unless sector.nil? or CompanyType[sector.upcase].nil?
    
    last_traded_date = params[:traded_on]
    return TradingMarket.last_traded_date_sql_cond(last_traded_date) unless last_traded_date.nil? or last_traded_date.empty?
    
    nil
  end
  
  def load_company
    company_id = params[:id]
    @company = cache_object(Company.table_name,company_id){|id|Company.find id}
  end
end
