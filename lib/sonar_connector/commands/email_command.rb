module Sonar
  module Connector
    class EmailCommand < Sonar::Connector::Command
      def initialize(connector,message)
        l = lambda do
          Sonar::Connector::Emailer.deliver_admin_message(connector, message)
        end
        super(l)
      end
    end
  end
end
