class SearchController < ApplicationController
  @@wild_character = "*"
  include SearchHelper
#  caches_action :show
  
  def auto_complete_for_search_term
    begin
      search_term = extract_search_term_parameter
      if search_term.empty? then
        render :inline => search_term
      else
        cache_block search_term do
          companies = Company.find_by_contents search_term
          result =  selected_matches search_term, companies.collect {|c| [c.stock_symbol, c.name]}
          render :inline => result, :type => :xml
         end
      end
    rescue 
      render :inline => ""
    end
  end
  
  def index
    search_term = extract_search_term_parameter
    unless search_term.nil?
      company_ids = Company.retrieve_ids_from_text_search search_term
      url = "http://" << request.host << ":" << request.port.to_s << "/companies"
      if company_ids.size == 1 then 
        headers["Status"] = "200"
        redirect_to url << "/" << company_ids.first
      else !company_ids.empty?
        redirect_to url << "?ids=" << company_ids.join(",") 
      end
    end
  end
  
  private
  def extract_search_term_parameter
    p = params[:search][:term] unless params[:search].nil?
    return nil if p.nil? or p.empty?
    params[:search][:term].strip + @@wild_character
  end
end