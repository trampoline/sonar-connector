module Sonar
  module Connector
    class SendAdminEmailCommand < Sonar::Connector::Command
      def initialize(connector, message)
        l = ->(_) {
          Sonar::Connector::Emailer.deliver_admin_message(connector, message)
        }
        super(l)
      end
    end
  end
end
