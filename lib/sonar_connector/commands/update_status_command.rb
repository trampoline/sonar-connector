module Sonar
  module Connector
    
    ACTION_OK = 'ok'
    ACTION_FAILED = 'failed'
    
    class UpdateStatusCommand < Sonar::Connector::Command
      def initialize(connector, field, value)
        l = lambda do
          status.set connector.name, field, value
        end
        super(l)
      end
    end
  end
end
