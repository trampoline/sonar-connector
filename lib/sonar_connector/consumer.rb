module Sonar
  module Connector
    
    ## 
    # Listens to thread message queue and processes messages.
    class Consumer
      
      attr_accessor :base_config
      attr_accessor :queue
      attr_accessor :log
      
      def initialize(base_config)
        @base_config = base_config
        
        # Creat logger and inherit the logger settings from the base controller config
        @log_file = File.join(base_config.log_dir, "consumer.log")
        @log = Logger.new STDOUT
        @log.level = base_config.log_level
      end
      
      def switch_to_log_file
        @log = Logger.new(@log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
      end
      
      ##
      # Main loop to watch the command queue and process commands.
      def watch(queue)
        switch_to_log_file
        
        while true
          command = queue.pop
          begin
            command.execute
          
          rescue ThreadTerminator
            log.warn "Consumer is shutting down and there are #{queue.size} unprocessed commands on the queue." if queue.size > 0
            log.info "Shut down consumer"
            log.close
            return true
            
          rescue Exception => e
            log.error "Command #{command.class} raised an unhandled exception: " + e.message + "\n" + e.backtrace.join("\n")
          end
          
        end
      end
      
    end
  end
end
