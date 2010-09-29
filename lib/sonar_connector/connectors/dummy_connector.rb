module Sonar
  module Connector
    
    ## 
    # Dummy connector type. Does nothing except report back to the controller.
    class DummyConnector < Sonar::Connector::Base
      
      def parse(config)
      end
      
      def action
        log.debug "#{name} mumbled incoherently to itself."
      end
      
    end
  end
end
