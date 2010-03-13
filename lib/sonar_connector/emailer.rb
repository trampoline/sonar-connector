module Sonar
  module Connector
    class Mailer < ActionMailer::Base
      def admin_warning_email(message)
        # from          Sonar::Connector::CONFIG.email_settings[""]
        # recipients    search.user.email
        # subject       "Bapzilla lunch recommendations for #{UserMailer.dayname}"
        # content_type  "text/html"
        # body          :search => search, :shops => shops
      end
    end
  end
end