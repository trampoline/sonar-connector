module Sonar
  module Connector
    class UpdateDiskUsageCommand < Sonar::Connector::Command
      def initialize(connector)
        l = lambda do
          du = (Sonar::Connector::Utils.du(connector.connector_dir).to_f / 1024).round_with_precision(2)
          Sonar::Connector::STATUS.set connector.name, 'disk_usage', "#{du} Kb"
        end
        super(l)
      end
    end
  end
end
