require 'singleton'

module Sonar
  module Connector
    class InvalidConfig < RuntimeError; end
    
    class Config

      attr_reader :base_dir
      attr_reader :log_dir
      attr_reader :log_level
      attr_reader :controller_log_file
      
      # Entry-point for creating and setting the CONFIG instance.
      # Give it a path to a JSON settings file and it'll do the rest.
      def self.read_config(config_file)
        config = Config.new(config_file).send(:parse!)
        Sonar::Connector.const_set("CONFIG", config)
      end
      
      def initialize(config_file)
        @raw_config = JSON.parse IO.read(config_file)
        # @base_dir = File.dirname(File.dirname(config_file))
      end
      
      private
      
      attr_reader :raw_config
      
      def parse!
        @log_level = parse_log_level @raw_config["log_level"]
        self
      end
      
      def parse_log_level(log_level)
        raise InvalidConfig.new("Config option 'log_level' is a required parameter.") if log_level.blank?
        valid_log_levels = ["debug", "info", "warn", "error", "fatal"]
        raise InvalidConfig.new("unknown log_level #{log_level}") unless valid_log_levels.include?(log_level)
        log_level.to_sym
      end
    end
  end
end

