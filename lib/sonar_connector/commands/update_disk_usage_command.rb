module Sonar
  module Connector
    class UpdateDiskUsageCommand < Sonar::Connector::Command
      def initialize(connector)
        l = ->(_) {
          du = (Sonar::Connector::Utils.du(connector.connector_dir).to_f / 1024).round
          status.set connector.name, 'disk_usage', "#{du} Kb"
        }
        super(l)
      end
    end
  end
end
