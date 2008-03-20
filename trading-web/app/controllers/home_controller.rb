class HomeController < ApplicationController
  def index
  end
  
  def pages
   render :file => "app/views/home/#{params[:id]}.html", :layout => true
  end
  
end
