module Sonar
  module Connector
    class Config
      include Singleton

      def initialize(config_file)
        # @raw_config = JSON.parse("{}")
      end

      def parse
      #   valid_keys = ["logging", "connectors", "environment"]
      #   raise InvalidConfig.new("invalid key") unless @raw_config.keys.foo
      # 
      #   @log_path = @raw_config["log_path"]
      #   raise InvalidConfig.new("invalid path") unless File.directory?(@log_path)
      # 
      #   @raw_config["connectors"]. bladsf
      # 
      #   connector_classes = [ExchangeConnector, SonarConnector]
      # 
      #   ExchangeConnector::Config.parse(exchange_config)
      # 
      # rescue InvalidConfig => e
      #   puts "Sorry, something wrong: #{e.message}"
      end
    end
  end
end
