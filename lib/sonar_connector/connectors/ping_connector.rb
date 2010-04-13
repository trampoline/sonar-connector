require 'net/ping'

module Sonar
  module Connector
    
    ##
    # A useful connector that pings a server regularly and logs an error when it can't ping. 
    # Use the following connector JSON config:
    # {
    #   "class": "Sonar::Connector::PingConnector",
    #   "name": "ping_connector1",
    #   "repeat_delay": 60,
    #   "host": "www.google.com"
    # }
    class PingConnector < Sonar::Connector::Base
      
      attr_reader :host
      attr_reader :port
      attr_reader :retry_count
      attr_accessor :consecutive_errors
      
      def parse(config)
        @host = config["host"]
        raise InvalidConfig.new("Connector '#{name}': host parameter cannot be blank") if @host.blank?
        @port = config["port"].blank? ? 80 : config["port"].to_i
        
        @retry_count = 4
        state[:consecutive_errors] = 0 unless state[:consecutive_errors]
      end
      
      def action
        if Net::Ping::External.new(host, port, 5).ping?
          state[:consecutive_errors] = 0
        else
          state[:consecutive_errors] += 1
          if state[:consecutive_errors] == retry_count
            state[:consecutive_errors] = 0
            queue.push Sonar::Connector::SendAdminEmailCommand.new(self, "tried to ping #{host} but failed to reach it #{retry_count} times")
          end
        end
      end
      
    end
  end
end
