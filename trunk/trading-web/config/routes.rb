ActionController::Routing::Routes.draw do |map|
   map.resources :stock_quotes, :companies, :feedbacks, :markets, :portfolios
  
   map.auth 'members/:action/:id', :controller => 'auth', :action => nil, :id => nil
   map.authadmin 'account/admin/:action/:id', :controller => 'authadmin', :action => nil, :id => nil
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  
#  # allow for searching view the route
#   map.connect 'search/*/auto_complete_for_search_term?search*', :controller => 'search', :action => '/auto_complete_for_search_term?search' 
#   map.connect 'search/:search_terms/:count', :controller => 'search', :action => 'index', :count => '-1' 
#
#  # allow for Open Search RSS feeds searching
#  map.connect 'rss/opensearch/description.xml', :controller => 'search', :action => 'description'
#  map.connect 'rss/opensearch/:search_terms/:count', :controller => 'search', :action => 'rss', :count => '-1'  
  
end
