require 'net/ping'

module Sonar
  module Connector
    
    # A useful connector that pings a server regularly and logs an error when it can't ping. 
    # Use the following connector JSON config:
    # {
    #   "type": "ping_connector",
    #   "name": "ping_connector1",
    #   "repeat_delay": 60,
    #   "host": "www.google.com"
    # }
    class PingConnector < Sonar::Connector::Base
      
      attr_accessor :host
      attr_accessor :port
      
      def parse(config)
        @host = config["host"]
        raise InvalidConfig.new("Connector '#{@name}': host parameter cannot be blank") if @host.blank?
        @port = config["port"].blank? ? 80 : config["port"].to_i
      end
      
      def action
        queue << "Connector '#{name}' couldn't ping host #{host}" unless Net::Ping::External.new(host, port, 5).ping?
      end
      
    end
  end
end
