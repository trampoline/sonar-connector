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
      
      attr_reader :base_config
      attr_reader :queue
      attr_reader :status
      attr_reader :log
      attr_reader :run
      
      def initialize(base_config)
        @base_config = base_config
        
        # Consumer holds the status object because changes 
        # to status should be centrally moderated.
        @status = Sonar::Connector::Status.new(@base_config)
        
        # Creat logger and inherit the logger settings from the base controller config
        @log_file = File.join(base_config.log_dir, "consumer.log")
        @log = Logger.new STDOUT
        @log.level = base_config.log_level
        
        @run = true
      end
      
      def switch_to_log_file
        FileUtils.mkdir_p(base_config.log_dir) unless File.directory?(base_config.log_dir)
        FileUtils.touch @log_file
        @log = Logger.new(@log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
      end
      
      def cleanup
        # TODO: why does this not work? queue.size and queue.empty? seem to block if used here.
        # log.warn "Consumer is shutting down and there are #{queue.size} unprocessed commands on the queue." unless queue.empty?
        log.info "Shut down consumer"
        log.close
      end
      
      ##
      # Main loop to watch the command queue and process commands.
      def watch(queue)
        @queue = queue
        switch_to_log_file
        
        while run
          begin
            command = queue.pop
            command.execute ExecutionContext.new(:log=>log, :status=>status)
          rescue ThreadTerminator
            @run = false
            break
          rescue Exception => e
            log.error "Command #{command.class} raised an unhandled exception: " + e.message + "\n" + e.backtrace.join("\n")
          end
        end
        
        cleanup
        true
      end
      
    end
  end
end
