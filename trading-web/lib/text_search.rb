module TextSearch
  def retrieve_ids_from_text_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 100, :page => 1}
    options = default_options.merge options
    options[:offset] = options[:limit] * (options[:page].to_i-1)
    results_ids = []
    
    self.ferret_index.search_each(q, options) { |doc, score|
      results_ids << self.ferret_index[doc]["id"]
    }
    
    return results_ids
  end
end