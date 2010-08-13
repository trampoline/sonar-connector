module Sonar
  module Connector
    
    class ThreadTerminator < Exception; end
    
    class Controller
      
      DEFAULT_CONFIG_FILENAME = "config/config.json"

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
      def initialize(config_filename = DEFAULT_CONFIG_FILENAME)
        @config = Sonar::Connector::Config.load config_filename
        @log = Sonar::Connector::Utils.stdout_logger @config

        @connectors = @config.connectors
        @consumer = Sonar::Connector::Consumer.new(@config)
        
        @threads = []
        
        @queue = Queue.new
        
        create_startup_dirs_and_files
      rescue Sonar::Connector::InvalidConfig => e
        $stderr << ([e.class.to_s, e.message, *e.backtrace].join("\n")) << "\n"
        raise RuntimeError, "Invalid configuration in #{config_filename}: \n #{e.message}"
      end
      
      def switch_to_log_file
        @log = Sonar::Connector::Utils.disk_logger(config.controller_log_file, config)
      end
      
      def start
        prepare_connector
        start_threads

        cleanup = lambda do
          puts "\nGiving threads 10 seconds to shut down..."
          threads.each{|t| t.raise(ThreadTerminator)}
          begin
            Timeout::timeout(10) { 
              threads.map(&:join)
            }
          rescue Timeout::Error
            puts "...couldn't stop all threads cleanly."
            log.info "Could not cleanly terminate all threads."
            log.close
            exit(1)
          rescue ThreadTerminator
            # ignore it, since it's come from one of the recently-nuked threads.
          rescue Exception => e
            log.debug ["Caught unhandled exception: ",
                       e.class.to_s,
                       e.message,
                       *e.backtrace].join("\n")
          end
          
          puts "...exited cleanly."
          log.info "Terminated all threads cleanly."
          log.close
          exit(0)
        end
        
        # let the controlling thread go into an endless sleep
        puts "Ctrl-C to stop."
        trap "SIGINT", cleanup
        endless_sleep
      end

      # prepare the connector, start an IRB console, but don't start any threads
      def start_console
        prepare_connector
        # make the Controller globally visible
        Connector.const_set("CONTROLLER", self)

        require 'irb'
        IRB.start
      end

      def prepare_connector
        switch_to_log_file
        log_startup_params
        
        connectors.each do |connector|
          log.info "preparing connector '#{connector.name}'"
          connector.prepare(queue)
        end

        log.info "preparing message queue consumer"
        consumer.prepare(queue)
      end

      ##
      # Main framework loop. Fire up one thread per connector, 
      # plus the message queue consumer. Then wait for quit signal.
      def start_threads
        # fire up the connector threads
        connectors.each do |connector|
          log.info "starting connector '#{connector.name}'"
          threads << Thread.new { connector.start }
        end
        
        log.info "starting the message queue consumer"
        threads << Thread.new{ consumer.watch }
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
