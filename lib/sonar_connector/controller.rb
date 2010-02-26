require 'rubygems'
require 'active_support'
require 'json'
require 'thread'
require 'logger'

module Sonar
  module Connector
    class Controller
      
      attr_reader :queue, :connectors, :log, :config
      
      def initialize(config_filename)
        # Parse the config file and create instances of each connector, 
        # parsing their config in turn.
        @config = Sonar::Connector::Config.read_config(config_filename)
        @connectors = @config.connectors
        
        @queue = Queue.new
        @log = Logger.new @config.controller_log_file
        @log.level = Logger.const_get @config.log_level.upcase
        
      rescue Sonar::Connector::InvalidConfig => e
        raise RuntimeError, "Invalid configuration in #{config_filename}: \n #{e.message}"
      end
      
      def start
        log_startup_params!
        create_startup_dirs_and_files!
        
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
      
      def log_startup_params!
        log.info "Startup: base directory is #{config.base_dir}"
        log.info "Startup: logging directory is #{config.log_dir}"
        log.info "Startup: log level is #{config.log_level}"
        log.info "Startup: controller logging to #{config.controller_log_file}"
      end

      def create_startup_dirs_and_files!
        FileUtils.mkdir_p(config.base_dir) unless File.directory?(config.base_dir)
        FileUtils.mkdir_p(config.log_dir) unless File.directory?(config.log_dir)
        FileUtils.touch config.controller_log_file
      end
      
    end
  end
end


