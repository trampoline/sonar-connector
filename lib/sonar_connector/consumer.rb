module Sonar
  module Connector
    
    # Command execution context, whereby commands can be injected with consumer context
    # variables for the logger and status objects.
    class ExecutionContext
        attr_reader :log
        attr_reader :status
        
        def initialize(params)
          @log = params[:log]
          @status = params[:status]
        end
    end
    
    
    ## 
    # Listens to thread message queue and processes messages.
    class Consumer
      
      attr_accessor :base_config
      attr_accessor :queue
      attr_accessor :status
      attr_accessor :log
      
      def initialize(base_config)
        @base_config = base_config
        
        # Consumer holds the status object because changes 
        # to status should be centrally moderated.
        @status = Sonar::Connector::Status.new(@base_config)
        
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
            command.execute ExecutionContext.new(:log=>@log, :status=>@status)
          
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
