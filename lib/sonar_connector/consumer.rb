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
        @log = Sonar::Connector::Utils.stdout_logger base_config
        
        @run = true
      end

      def prepare(queue)
        @queue = queue
        switch_to_log_file
      end
      
      def switch_to_log_file
        FileUtils.mkdir_p(base_config.log_dir) unless File.directory?(base_config.log_dir)
        @log = Sonar::Connector::Utils.disk_logger(@log_file, base_config)
      end
      
      def cleanup
        log.info "Shut down consumer"
        log.close
      end
      
      ##
      # Main loop to watch the command queue and process commands.
      def watch
        while run
          begin
            run_once
          rescue ThreadTerminator
            break
          end
        end
        
        @run = false
        cleanup
        true
      end

      def run_once
        begin
          command = queue.pop
          command.execute ExecutionContext.new(:log=>log, :status=>status)
        rescue ThreadTerminator => e
          raise
        rescue Exception => e
          log.error ["Command #{command.class} raised an unhandled exception: ",
                     e.class.to_s, e.message, *e.backtrace].join('\n')
        end
      end
    end
  end
end
