module Sonar
  module Connector
    
    ##
    # Base command class that all commands should subclass.
    
    class Command
      
      def initialize(proc)
        @proc = proc
      end

      def execute(context)
        context.instance_eval(&@proc)
      end
      
    end
  end
end
