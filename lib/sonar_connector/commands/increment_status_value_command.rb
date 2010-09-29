module Sonar
  module Connector
    
    class IncrementStatusValueCommand < Sonar::Connector::Command
      def initialize(connector, field, value = 1)
        l = lambda do
          current = status[connector.name] ? status[connector.name][field].to_i : 0
          status.set connector.name, field, current+value
        end
        super(l)
      end
    end
  end
end
