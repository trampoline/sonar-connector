module Sonar
  module Connector
    
    ACTION_OK = 'ok'
    ACTION_FAILED = 'failed'
    
    class UpdateStatusCommand < Sonar::Connector::Command
      def initialize(connector, field, value)
        l = ->(_) {
          status.set connector.name, field, value
        }
        super(l)
      end
    end
  end
end
