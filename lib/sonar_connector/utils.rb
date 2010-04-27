module Sonar
  module Connector
    module Utils
      
      #
      # Disk usage utility. Returns amount of disk space 
      # used in a given folder, in bytes.
      def du(dir)
        raise "#{dir} is not a directory" unless File.directory?(dir)
        glob = File.join(dir, "**", "*")
        Dir[glob].map {|f|
          File.read(f).size rescue nil
        }.compact.sum
      end
      
      module_function :du
      
      def timestamped_id(prefix=nil)
        t = Time.now
        [prefix, t.to_i * 1000000 + t.usec].compact.join("_")
      end
      
      module_function :timestamped_id
      
      def stdout_logger(base_config)
        log = Logger.new STDOUT
        log.level = base_config.log_level
        log.formatter = Logger::Formatter.new
        log.datetime_format = "%Y-%m-%d %H:%M:%S"
        log
      end
      
      module_function :stdout_logger
      
      def disk_logger(filename, base_config)
        log = Logger.new filename, base_config.log_files_to_keep, base_config.log_file_max_size
        log.level = base_config.log_level
        log.formatter = Logger::Formatter.new
        log.datetime_format = "%Y-%m-%d %H:%M:%S"
        log
      end
      
      module_function :disk_logger
    end
  end
end