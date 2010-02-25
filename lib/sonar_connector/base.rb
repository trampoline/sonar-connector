module Sonar
  module Connector
    class Base
      
      attr_reader :logger, :queue
      
      def initialize(queue)
        # initialise logger here too
        @queue = queue
      end
      
    end
  end
end