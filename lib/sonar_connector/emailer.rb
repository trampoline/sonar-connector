module Sonar
  module Connector
    class Emailer < ActionMailer::Base
      def admin_message(connector, message)
        from          Sonar::Connector::CONFIG.email_settings["admin_sender"]
        recipients    Sonar::Connector::CONFIG.email_settings["admin_recipients"]
        subject       "Admin email from Sonar Connector"
        content_type  "text/plain"
        body          <<-BODY
Admin email from Sonar Connector. The connector '#{connector.name}' sent the following message:
#{message}
BODY
      end
    end
  end
end