module Sonar
  module Connector
    class InvalidConfig < RuntimeError; end
    
    class Config

      attr_reader :base_dir
      attr_reader :log_dir
      attr_reader :log_level
      attr_reader :controller_log_file
      attr_reader :connectors
      
      # Entry-point for creating and setting the CONFIG instance.
      # Give it a path to the JSON settings file and it'll do the rest.
      def self.read_config(config_file)
        config = Config.new(config_file).parse!
        Sonar::Connector.const_set("CONFIG", config)
      end
      
      def initialize(config_file)
        @config_file = config_file
      end
      
      def parse!
        @raw_config = JSON.parse IO.read(@config_file)
        
        # extract the core config params
        @base_dir = parse_base_dir @raw_config["base_dir"]
        @log_dir = File.join @base_dir, 'log'
        @controller_log_file = File.join @log_dir, 'controller.log'
        @log_level = parse_log_level @raw_config["log_level"]
        
        # extract each connector, locate its class and attempt to parse its config
        @connectors = parse_connectors @raw_config["connectors"]
        
        self
      rescue JSON::ParserError => e
        raise InvalidConfig.new("Config file #{config_file} is not in a valid JSON format. Please check the contents \
        carefully. This is the exact error: \n#{e.message}")
      end

      private
      
      attr_reader :config_file
      attr_reader :raw_config
      
      def parse_base_dir(base_dir)
        d = base_dir.blank? ? File.dirname(File.dirname(@config_file)) : base_dir
        raise InvalidConfig.new("#{d} not a valid directory") unless File.directory?(d)
        d
      end
      
      def parse_log_level(log_level)
        raise InvalidConfig.new("Config option 'log_level' is a required parameter.") if log_level.blank?
        valid_log_levels = ["debug", "info", "warn", "error", "fatal"]
        raise InvalidConfig.new("unknown log_level #{log_level}") unless valid_log_levels.include?(log_level)
        log_level
      end
      
      def parse_connectors(connector_settings)
        c = []
        connector_settings.each do |settings|
          c << parse_connector(settings)
        end
        
        raise InvalidConfig.new("Connector names must be unique. You supplied: #{c.map(&:name).inspect}") if c.map(&:name).uniq.size != c.size
        c
      end
      
      def parse_connector(settings)
        # first see if this class is already loaded
        type = settings["type"]
        raise InvalidConfig.new("Error with connector settings '#{settings.inspect}': parameter 'type' must be specified") if type.blank?
        
        klass = type.camelize.constantize rescue nil
        
        # try in the Sonar::Connector module space
        klass = ("sonar/connector/"+type).camelize.constantize rescue nil
        
        # try again with require
        unless klass
          require type rescue nil
          klass = type.camelize.constantize rescue nil
        end
        
        # give up if it still doesn't exist
        raise InvalidConfig.new("Error with connector '#{type}': could not find a class for it called #{type.camelize}") unless klass
        
        # sanity-check that the connector class subclasses the base
        raise InvalidConfig.new("Connector class #{klass.name} must subclass Sonar::Connector::Base") unless klass.ancestors.include?(Sonar::Connector::Base)
        klass.new(settings)
      end
      
    end
  end
end

