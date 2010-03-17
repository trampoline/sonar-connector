module Sonar
  module Connector
    class Controller
      
      ##
      # single command queue for threads to communicate with the controller
      attr_reader :queue
      
      ##
      # array of instantiated connector instances
      attr_reader :connectors

      ##
      # message consumer
      attr_reader :consumer
      
      ##
      # controller logger
      attr_reader :log
      
      ##
      # instance of Sonar::Connector::Config
      attr_reader :config
      
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
        @threads = []
        
        @queue = Queue.new
        @log = Logger.new STDOUT
        @log.level = @config.log_level
        
        @stop = false
        
      rescue Sonar::Connector::InvalidConfig => e
        raise RuntimeError, "Invalid configuration in #{config_filename}: \n #{e.message}"
      end
      
      def switch_to_log_file
        @log = Logger.new(config.controller_log_file, config.log_files_to_keep, config.log_file_max_size)
      end
      
      ##
      # Main connector loop. Fire up one thread per connector, 
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
        #threads << Thread.new{ consumer.watch(queue) }
        Thread.new{ consumer.watch(queue) }
        
        puts "Ctrl-C to stop."
        trap "SIGINT", proc{ stop! }
        
        while !stop?
          sleep(0.1)
        end
        
        puts "Waiting 10 seconds for connectors to shut down"
        connectors.map(&:stop!)
        begin
          Timeout::timeout(10) { threads.map(&:join) }
          puts "Exited cleanly."
        rescue Timeout::Error
          puts "Couldn't stop all threads cleanly. Meh."
        end
        
      end
      
      private
      
      def stop!
        @stop = true
      end
      
      def stop?
        @stop
      end
      
      def log_startup_params
        log.info "Startup: base directory is #{config.base_dir}"
        log.info "Startup: logging directory is #{config.log_dir}"
        log.info "Startup: log level is #{config.log_level}"
        log.info "Startup: controller logging to #{config.controller_log_file}"
      end

      def create_startup_dirs_and_files
        FileUtils.mkdir_p(config.base_dir) unless File.directory?(config.base_dir)
        FileUtils.mkdir_p(config.log_dir) unless File.directory?(config.log_dir)
        FileUtils.touch config.controller_log_file
      end
      
    end
  end
end


