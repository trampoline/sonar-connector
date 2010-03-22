module Sonar
  module Connector
    
    CONNECTOR_OK = 'ok'
    CONNECTOR_ERROR = 'error'
    
    class UpdateStatusCommand < Sonar::Connector::Command
      def initialize(connector, msg)
        l = lambda do
          status.set connector.name, 'status', msg
        end
        super(l)
      end
    end
  end
end
