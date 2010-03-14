module Sonar
  module Connector
    
    ##
    # Base command class that all commands should subclass.
    
    class Command
      
      attr_accessor :params
      
      class << self
        class_eval do
          def schedule(*params)
            c = self.new
            c.params = params
            c
          end
        end
      end
      
    end
  end
end
