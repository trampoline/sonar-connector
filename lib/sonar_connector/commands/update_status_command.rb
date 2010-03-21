module Sonar
  module Connector
    
    CONNECTOR_OK = 'ok'
    CONNECTOR_ERROR = 'error'
    
    class UpdateStatusCommand < Sonar::Connector::Command
      def initialize(connector, status)
        l = lambda do
          Sonar::Connector::STATUS.set(connector.name, 'status', status)
        end
        super(l)
      end
    end
  end
end
