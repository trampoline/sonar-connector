module Sonar
  module Connector
    
    ## 
    # Dummy connector type. Does nothing except report back to the controller.
    class DummyConnector < Sonar::Connector::Base
      
      def parse(config)
      end
      
      def action
        queue.push "#{name} mumbled aimlessly at #{Time.now.to_s}"
      end
      
    end
  end
end
