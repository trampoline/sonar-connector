require 'singleton'

module Sonar
  module Connector
    class InvalidConfig < RuntimeError; end
    
    class Config
      
      attr_reader :log_level
      
      # Entry-point for creating and setting the CONFIG instance.
      # Give it a path to a JSON settings file and it'll do the rest.
      def self.create(config_file)
        raw_config = JSON.parse IO.read(config_file)
        config = Config.new(raw_config)
        config.send(:parse!)
        
        Sonar::Connector.const_set(:"CONFIG", config)
      end
      
      def initialize(raw_config)
        @raw_config = raw_config
      end
      
      private
      
      attr_reader :raw_config
      
      def parse!
        @log_level = :warn
      end
      
    end
  end
end

