class MarketsController < ApplicationController

  def top_movers
    top_type = SqlCommandType.look_up params[:id]
    cache_block 'top_movers:'+params[:id] do
      render :partial => 'top_movers_content', :locals => { :top_mover_type => top_type}
    end
  end
  
  def show
    symbol = params[:id]
    @market = TradingMarket.find_by_stock_symbol(symbol)
    @market||= TradingMarket.new
    render :json => @market.attributes.to_json
  end
end