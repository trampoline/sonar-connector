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
        @log = Logger.new(base_config.controller_log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
      end
      
      def watch(queue)
        switch_to_log_file
        
        while true
          message = queue.pop
          # process the queue here
          log.info "consumed message: #{message}"
        end
      end
      
    end
  end
end