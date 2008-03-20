# Put your code that runs your task inside the do_work method
# it will be run automatically in a thread. You have access to
# all of your rails models if you set load_rails to true in the
# config file. You also get @logger inside of this class by default.
class SchedulerWorker < BackgrounDRb::Rails
  FROM_HOUR= 18
  THROUGH_HOUR = 22
  
  repeat_every  2.hours
  first_run Time.now + 2.hours
  
  def do_work(args)
    begin
      return unless time_to_run? 
      return if file_aready_created?

      @logger.info "\n\n>>>>>>>>>>>>>>>>>>>>>>> This daemon is still running at: #{Time.now}. <<<<<<<<<<<<<<<<<<<<<<<<<<<\n"
      flush_cache CACHE
      flush_cache ActionController::Base.fragment_cache_store
      result =  system("ruby #{RAILS_ROOT}/script/loader -t web")
      @logger.info "@@@@@@@@@@@@@@@@ The execution was #{result}"
      @logger.info "Last traded prices collection parsing has finished at #{Time.now}.\n" 
    
      change_index_perm if result
#     clear_unused_sessions
     
    rescue Exception => e
      @logger.error "Critical error in scheduler...."
      @logger.error e.inspect
    end
  end
  
  private
  def flush_cache cache
    return unless cache
    
    @logger.info "flushing cache for #{cache}..."
    
    if cache.respond_to? :clear
      @logger.info ':::::::::::::::::: Clearing Cache :::::::::::::::::::::::::'
      cache.clear 
    elsif cache.respond_to? :flush
      @logger.info ':::::::::::::::::: Flushing Cache :::::::::::::::::::::::::'
      cache.flush 
    elsif cache.respond_to? :flush_all
      @logger.info ':::::::::::::::::: Flushing All Cache :::::::::::::::::::::::::'
      cache.flush_all
    end
  end
  
  def change_index_perm
    system("sudo chmod -R 7777 " + RAILS_ROOT + "/index/production/company")
    system("sudo chmod -R 7777 " + RAILS_ROOT + "/index/production/company/segments")
    system("sudo chmod -R 7777 " + RAILS_ROOT + "/index/production/company/fields")
    system("sudo chmod -R 7777 " + RAILS_ROOT + "/index/production/company/*")
    @logger.info "Changed permissions for index folder at #{Time.now}.\n" 
  end
  
  def clear_unused_sessions
     session_expires = Time.new - 8.hours
     path = RAILS_ROOT + '/tmp/sessions/'
     entries = Dir.entries(path)
     ruby_sess = 'ruby_sess'
     entries.each do |file_name|
        next unless file_name.match(/#{ruby_sess}/)
        begin
          file_path = path + file_name
          mtime = File.mtime(file_path)
          File.delete(file_path) if mtime < session_expires 
        rescue Exception => e
          @logger.error 'Exception during deleting of session files'
          @logger.error e
        end
     end
  end
  
  def time_to_run?
    t = Time.now 
    t =  t.gmtime + 2.hours    
    current_hour = t.hour    
    THROUGH_HOUR >= current_hour and current_hour >= FROM_HOUR
  end
  
  def file_aready_created?
    File.exists?(RAILS_ROOT + "/data/last_traded_prices/LastTradedPrice_#{Time.new.strftime('%Y_%m_%d')}")
  end
end
