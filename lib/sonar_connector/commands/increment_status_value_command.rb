module Sonar
  module Connector
    
    class IncrementStatusValueCommand < Sonar::Connector::Command
      def initialize(connector, field, value = 1)
        l = ->(_) {
          current = status[connector.name] ? status[connector.name][field].to_i : 0
          status.set connector.name, field, current+value
        }
        super(l)
      end
    end
  end
end
