module Sonar
  module Connector
    class EmailCommand < Sonar::Connector::Command
      
      def execute(connector, message)
        Sonar::Connector::Emailer.deliver_admin_message(connector, message)
      end
    end
  end
end
