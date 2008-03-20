def require_all_files(path)
  $:.push path          # resource path
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

module FileParser
  def execute_locally file_path, file_type = 'html'
    total_count = 0
    error_count = 0
    log_exception do
      path = File.join File.dirname(__FILE__), file_path
      entries = Dir.entries(path)
      entries = entries.sort
      entries.each do |file_name|
        next unless file_name.match(/#{file_type}/)
        logger.info file_name
        failed = false
        exc_thrown = log_exception do
          file = File.open path + file_name, "r"
          failed = yield(file)
        end 
        if exc_thrown or failed
          error_count+=1
        else
          total_count +=1
        end
      end
    end
    
    logger.info "\n\n &&&&&&&&&&&&&&&&&&&&&&&&&& Local data loading has finished. Results: &&&&&&&&&&&&&&&&&&&&&&&&"
    logger.info "TOTAL PROCESSED: #{total_count} | ERRORS: #{error_count}"
    logger.info "--------------------------------------------------------------------------------"
  end
end

def log_exception 
  begin
    yield
  rescue Exception => e
    logger.error e
    return true
  end
  return false
end

