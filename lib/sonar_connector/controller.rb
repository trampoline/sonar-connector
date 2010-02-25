require 'rubygems'
require 'json'
require 'thread'

module Sonar
  module Connector
    class Controller
      
      attr_reader :queue, :connector_threads
            
      def initialize(config_filename)
        @config_filename = config_filename
        @queue = Queue.new
        @connector_threads = []
      end
      
      def start
        puts "reading config from #{@config_filename}"
        # read config here

        puts "starting connectors"
        # start connectors here
        
        d = DummyConnector.new(@queue)
        @connector_threads << Thread.new {d.run}
        
        puts "listening to the queue"
        
        while true
          message = @queue.pop
          # process the queue here
          puts "consumed message: #{message}"
        end
      end
      
    end
  end
end


