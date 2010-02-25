module Sonar
  module Connector
    class DummyConnector < Sonar::Connector::Base
      
      def run
        i = 0
        while true
          @queue.push("message number #{i}")
          i += 1
          sleep(1)
        end
      end
      
    end
  end
end
