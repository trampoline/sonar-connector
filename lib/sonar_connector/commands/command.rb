module Sonar
  module Connector
    
    ##
    # Base command class that all commands should subclass.
    
    class Command
      
      def initialize(proc)
        @proc = proc
      end

      def execute
        @proc.call
      end
      
    end
  end
end
