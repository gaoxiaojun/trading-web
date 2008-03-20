class FeedbacksController < ApplicationController
  include AjaxScaffold::Controller
   
  before_filter :update_params_filter
  
  def update_params_filter
    @stylesheets = %w[ajax_scaff]
    update_params :default_scaffold_id => "feedback", :default_sort => nil, :default_sort_direction => "desc"
  end
  
  def index
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
    @sort_sql = Feedback.scaffold_columns_hash[current_sort(params)].sort_sql rescue nil
    options = { :order => @sort_sql, :per_page => 10}
  
    @sort_by = @sort_sql.nil? ? "#{Feedback.table_name}.#{Feedback.primary_key} asc" : @sort_sql  + " " << current_sort_direction(params)
    options[:order] = @sort_by
    @paginator, @feedbacks = paginate(:feedbacks, options)
    render :action => "component", :layout => false
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.xml
  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @feedback.to_xml }
    end
  end

  # GET /feedbacks/new
  def new
    flash[:edit] = false
    @feedback = Feedback.new
  end

  # GET /feedbacks/1;edit
  def edit
    flash[:edit]= true
    @feedback = Feedback.find(params[:id])
    #    @feedback.email= @feedback.obstructed_email
    render :action => 'new'
  end

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])

    respond_to do |format|
      if @feedback.save
        flash[:feed_key] = @feedback.editable_key
        flash[:notice] = 'Your Feedback was successfully created.Thank you! We really appreciate you participation.'
        format.html { redirect_to feedback_url(@feedback) }
        format.xml  { head :created, :location => feedback_url(@feedback) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors.to_xml }
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    flash[:edit]= true
    @feedback = Feedback.find(params[:id])
    
    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        flash[:feed_key] = @feedback.editable_key
        flash[:notice] = 'Your Feedback was successfully updated.Thank you! We really appreciate you participation.'
        format.html { redirect_to feedback_url(@feedback) }
        format.xml  { head :ok }
      else
        flash[:edit]= true
        params[:key]= params[:feedback][:key]
        format.html { render :action => 'new' }
        format.xml  { render :xml => @feedback.errors.to_xml }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.key= params[:key]
    @feedback.destroy
    flash[:notice] = 'The Feedback was successfully deleted!'
    respond_to do |format|
      format.html { redirect_to feedbacks_url }
      format.xml  { head :ok }
    end
  end
end
