module Sonar
  module Connector
    class DummyConnector < Sonar::Connector::Base
      
      def parse(config)
        
      end
      
      def action
        queue.push("#{name} mumbled aimlessly at #{Time.now.to_s}")
      end
      
    end
  end
end
