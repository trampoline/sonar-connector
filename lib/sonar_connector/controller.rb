module Sonar
  module Connector
    class Controller
      
      def initialize(config_filename)
        @config_filename = config_filename
      end
      
      def go
        puts "reading config from #{@config_filename}"
        
      end
      
    end
  end
end
  