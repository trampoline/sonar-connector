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
        config = Config.new(config_file).parse!
        Sonar::Connector.const_set("CONFIG", config)
      end
      
      def initialize(config_file)
        @config_file = config_file
      end

      def parse!
        @raw_config = JSON.parse IO.read(@config_file)
        @base_dir = parse_base_dir @raw_config["base_dir"]
        @log_dir = File.join @base_dir, 'log'
        @controller_log_file = File.join @log_dir, 'controller.log'
        @log_level = parse_log_level @raw_config["log_level"]
        self
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
    end
  end
end

