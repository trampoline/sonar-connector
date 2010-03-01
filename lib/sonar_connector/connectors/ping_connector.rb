require 'net/ping'

module Sonar
  module Connector
    class PingConnector < Sonar::Connector::Base
      
      attr_accessor :host
      attr_accessor :port
      
      def parse(config)
        @host = config["host"]
        raise InvalidConfig.new("Connector '#{@name}': host parameter cannot be blank") if @host.blank?
        config["port"].blank? ? @port = 80 : config["port"].to_i
      end
      
      def action
        queue << "Connector '#{name}' couldn't ping host #{host}" unless Net::Ping::External.new(host, port, 5).ping?
      end
      
    end
  end
end
