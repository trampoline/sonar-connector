module Sonar
  module Connector
    
    class ThreadTerminator < Exception; end
    
    class Controller
      
      ##
      # single command queue for threads to communicate with the controller
      attr_reader :queue
      
      ##
      # array of instantiated connector instances
      attr_reader :connectors

      ##
      # instance of Sonar::Connector::Consumer
      attr_reader :consumer
      
      ##
      # instance of Sonar::Connector::Config
      attr_reader :config
      
      ## 
      # instance of Sonar::Connector::Status
      attr_reader :status
      
      ##
      # controller logger
      attr_reader :log
      
      ##
      # array of threads
      attr_reader :threads
      
      ##
      # Parse the config file and create instances of each connector, 
      # parsing their config in turn.
      def initialize(config_filename)
        @config = Sonar::Connector::Config.load config_filename
        @connectors = @config.connectors
        @consumer = Sonar::Connector::Consumer.new(@config)
        
        # uuuugly
        @status = Sonar::Connector::Status.new(@config)
        Sonar::Connector.const_set("STATUS", @status)
        
        @threads = []
        
        @queue = Queue.new
        @log = Logger.new STDOUT
        @log.level = @config.log_level
        
      rescue Sonar::Connector::InvalidConfig => e
        raise RuntimeError, "Invalid configuration in #{config_filename}: \n #{e.message}"
      end
      
      def switch_to_log_file
        @log = Logger.new(config.controller_log_file, config.log_files_to_keep, config.log_file_max_size)
      end
      
      ##
      # Main framework loop. Fire up one thread per connector, 
      # plus the message queue consumer. Then wait for quit signal.
      def start
        create_startup_dirs_and_files
        switch_to_log_file
        log_startup_params
        
        # fire up the connector threads
        connectors.each do |connector|
          log.info "starting connector '#{connector.name}'"
          threads << Thread.new { connector.run(queue) }
        end
        
        log.info "starting the message queue consumer"
        threads << Thread.new{ consumer.watch(queue) }
        
        cleanup = lambda {
          puts "\nGiving threads 10 seconds to shut down..."
          threads.each{|t| t.raise(ThreadTerminator.new)}
          begin
            Timeout::timeout(10) { 
              threads.map(&:join) }
          rescue Timeout::Error
            puts "...couldn't stop all threads cleanly."
            log.info "Could not cleanly terminate all threads."
            log.close
            exit(1)
          rescue Exception => e
            # do nothing - don't care about exceptions from dying threads.
          end
          
          puts "...exited cleanly."
          log.info "Terminated all threads cleanly."
          log.close
          exit(0)
          
        }
        
        # let the controlling thread go into an endless sleep.
        puts "Ctrl-C to stop."
        trap "SIGINT", cleanup
        endless_sleep
      end
      
      private
      
      def log_startup_params
        log.info "Startup: base directory is #{config.base_dir}"
        log.info "Startup: logging directory is #{config.log_dir}"
        log.info "Startup: log level is " + config.send(:raw_config)['log_level']
        log.info "Startup: controller logging to #{config.controller_log_file}"
      end
      
      def create_startup_dirs_and_files
        FileUtils.mkdir_p(config.base_dir) unless File.directory?(config.base_dir)
        FileUtils.mkdir_p(config.log_dir) unless File.directory?(config.log_dir)
        FileUtils.touch config.controller_log_file
      end
      
      def endless_sleep
        sleep
      end
      
    end
  end
end
