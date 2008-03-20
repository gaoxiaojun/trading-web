require 'logger'

class Logger
  @@file_loggers = {}
  @@log_to_file = true
  
  def self.logger_for_scrap_parser
    logger  'scrap_parser'
  end
  
  def self.logger_for_data_conversion
    logger  'data_conversion'
  end
  
  def self.logger log_name
    logger = @@file_loggers[log_name]
    return logger if logger
    
    logger = initialize_logger(log_file(log_name))
    @@file_loggers[log_name] = logger
  end
  
  def self.reset_logger log_name
     @@file_loggers[log_name] = nil
  end
  
  def self.reset_loggers
    @@file_loggers = {}
  end
  
  def self.date_format
    "%Y-%m-%d %H:%M:%S"
  end
  
  def self.period
    'daily'
  end
  
  def debug(progname = nil, &block)
#    puts progname if debug?
    add(DEBUG, nil, progname, &block)
  end

  def info(progname = nil, &block)
    puts progname if info?
    add(INFO, nil, progname, &block)
  end

  def warn(progname = nil, &block)
    puts progname if warn?
    add(WARN, nil, progname, &block)
  end

  def error(progname = nil, &block)
    puts progname if error?
    add(ERROR, nil, progname, &block)
  end

  def fatal(progname = nil, &block)
    puts progname if fatal?
    add(FATAL, nil, progname, &block)
  end
  
  
  private
  def self.initialize_logger name
    logger = Logger.new(name, 10, 1024000)
    logger.level = Logger::INFO
    logger.datetime_format = date_format
    logger
  end
  
  def self.log_file log_name
     "#{RAILS_ROOT}/log/#{log_name}.log"
  end
end

