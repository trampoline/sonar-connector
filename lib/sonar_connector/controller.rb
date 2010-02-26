require 'rubygems'
require 'json'
require 'thread'
require 'logger'

module Sonar
  module Connector
    class Controller
      
      attr_reader :queue, :connector_threads, :log, :config
            
      def initialize(config_filename)
        @config = Sonar::Connector::Config.read_config(config_filename)
        @queue = Queue.new
        @connector_threads = []
        @log = Logger.new(@config.controller_log_file)
        @log.level = Logger.const_get(@config.log_level.upcase)
        
        log_startup_params!
        create_startup_dirs_and_files!
        
      end
      
      def start
        puts "starting connectors"
        # start connectors here
        
        d = DummyConnector.new(queue)
        connector_threads << Thread.new {d.run}
        
        puts "listening to the queue"
        
        while true
          message = queue.pop
          # process the queue here
          puts "consumed message: #{message}"
        end
      end
      
      private
      
      def log_startup_params!
        log.info "Startup: base directory is #{@config.base_dir}"
        log.info "Startup: logging directory is #{@config.log_dir}"
        log.info "Startup: log level is #{@config.log_level}"
        log.info "Startup: controller logging to #{@config.controller_log_file}"
      end

      def create_startup_dirs_and_files!
        FileUtils.mkdir_p(@config.base_dir) unless File.directory?(@config.base_dir)
        FileUtils.mkdir_p(@config.log_dir) unless File.directory?(@config.log_dir)
        FileUtils.touch(@config.controller_log_file)
      end
      
    end
  end
end


