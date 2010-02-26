module Sonar
  module Connector
    class Base
      
      attr_reader :name, :logger
      
      def initialize(settings)
        @name = settings["name"]
        
        parse settings
        
        # initialise logger here
      end
      
      def parse(settings)
        raise InvalidConfig.new("class #{self.class} must implement #parse method")
      end
      
    end
  end
end