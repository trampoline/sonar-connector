module Sonar
  module Connector
    class Base
      
      attr_reader :logger, :queue
      
      def initialize(queue)
        @logger = Sonar::Connector::Logger.new
        @queue = queue
      end
      
    end
  end
end