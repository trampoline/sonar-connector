require 'rubygems'
require 'active_support'
require 'json'
require 'thread'
require 'logger'

module Sonar
  module Connector
    class Controller
      
      # single command queue for threads to communicate with the controller
      attr_reader :queue
      
      # array of instantiated connector instances
      attr_reader :connectors
      
      # controller logger
      attr_reader :log
      
      # instance of Sonar::Connector::Config
      attr_reader :config
      
      def initialize(config_filename)
        
        # Parse the config file and create instances of each connector, 
        # parsing their config in turn.
        @config = Sonar::Connector::Config.load config_filename
        @connectors = @config.connectors
        
        @queue = Queue.new
        @log = Logger.new(@config.controller_log_file, @config.log_files_to_keep, @config.log_file_max_size)
        @log.level = @config.log_level
        
      rescue Sonar::Connector::InvalidConfig => e
        raise RuntimeError, "Invalid configuration in #{config_filename}: \n #{e.message}"
      end
      
      
      # Main connector loop. Fire up one thread per connector, and monitor the queue.
      def start
        log_startup_params
        create_startup_dirs_and_files
        
        # fire up the connector threads
        connectors.each do |connector|
          log.info "starting connector '#{connector.name}'"
          Thread.new { connector.run(queue) }
        end
        
        log.info "listening to the queue"
        while true
          message = queue.pop
          # process the queue here
          log.info "consumed message: #{message}"
        end
      end
      
      private
      
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


