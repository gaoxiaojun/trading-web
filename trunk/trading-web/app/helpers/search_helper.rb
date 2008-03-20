require 'rubygems'
gem 'builder', '~> 2.0'

module SearchHelper
  def selected_matches (search_term, results)
    return "" if search_term.nil? || results.nil? || results.empty?
    search_term = search_term.gsub(/\*/i, '');
    xml = "<ul>" 
    results.each do |result| 
      xml << "<li>"
      for i in 0...result.size
        xml << "<span class='informal'>, " unless i == 0
        xml << result[i].gsub(/(#{search_term})/i , '<strong>\1</strong>')
        xml << "</span>" unless i == 0
      end
      xml << "</li>"
    end
    xml << "</ul>" 
  end
end