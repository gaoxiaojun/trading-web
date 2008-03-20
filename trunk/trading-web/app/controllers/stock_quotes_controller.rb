class StockQuotesController < ApplicationController
  # GET /stock_quotes
  # GET /stock_quotes.xml
  def index
    @stock_quotes = StockQuote.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @stock_quotes.to_xml }
    end
  end

  # GET /stock_quotes/1
  # GET /stock_quotes/1.xml
  def show
    @stock_quote = StockQuote.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @stock_quote.to_xml }
    end
  end

  # GET /stock_quotes/new
  def new
    @stock_quote = StockQuote.new
  end

  # GET /stock_quotes/1;edit
  def edit
    @stock_quote = StockQuote.find(params[:id])
  end

  # POST /stock_quotes
  # POST /stock_quotes.xml
  def create
    @stock_quote = StockQuote.new(params[:stock_quote])

    respond_to do |format|
      if @stock_quote.save
        flash[:notice] = 'StockQuote was successfully created.'
        format.html { redirect_to stock_quote_path(@stock_quote) }
        format.xml  { head :created, :location => stock_quote_path(@stock_quote) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_quote.errors.to_xml }
      end
    end
  end

  # PUT /stock_quotes/1
  # PUT /stock_quotes/1.xml
  def update
    @stock_quote = StockQuote.find(params[:id])

    respond_to do |format|
      if @stock_quote.update_attributes(params[:stock_quote])
        flash[:notice] = 'StockQuote was successfully updated.'
        format.html { redirect_to stock_quote_path(@stock_quote) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_quote.errors.to_xml }
      end
    end
  end

  # DELETE /stock_quotes/1
  # DELETE /stock_quotes/1.xml
  def destroy
    @stock_quote = StockQuote.find(params[:id])
    @stock_quote.destroy

    respond_to do |format|
      format.html { redirect_to stock_quotes_path }
      format.xml  { head :ok }
    end
  end
end
