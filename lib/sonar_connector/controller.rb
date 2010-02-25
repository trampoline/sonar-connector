require 'rubygems'
require 'json'
require 'singleton'
require 'thread'

module Sonar
  module Connector
    class Controller
      
      attr_reader :queue, :connectors
      
      def initialize(config_filename)
        @config_filename = config_filename
        @queue = Queue.new
        @connectors = []
      end
      
      def go
        puts "reading config from #{@config_filename}"
        
        puts "starting connectors"
        
        d = DummyConnector.new(@queue)
        @connectors << d
        Thread.new {d.run}
        
        puts "listening to the queue"
        
        while true
          message = @queue.pop
          puts "consumed message: #{message}"
        end
        
      end
      
    end
  end
end
  