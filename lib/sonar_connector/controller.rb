require 'rubygems'
require 'json'
require 'thread'
require 'logger'

module Sonar
  module Connector
    class Controller
      
      attr_reader :queue, :connector_threads, :logger, :config
            
      def initialize(config_filename)
        Sonar::Connector::Config.parse(config_filename)
        @config = Sonar::Connector::CONFIG
        @queue = Queue.new
        @connector_threads = []
        @log = Logger.new()
        @log.level = @config["log_level"]
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
      
    end
  end
end


