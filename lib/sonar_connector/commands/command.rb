module Sonar
  module Connector
    
    ##
    # Base command class that all commands should subclass.
    
    class Command
      
      attr_accessor :proc
      
      def initialize(proc)
        @proc = proc
      end
      
      def execute(context = nil)
        context.instance_eval(&@proc)
      end
      
    end
  end
end
