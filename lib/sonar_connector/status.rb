module Sonar
  module Connector
    
    # Represents the status and statistics collected by various connectors
    # and is responsible for accessing, updating and persisting the status YAML file.
    class Status
      
      def initialize(config)
        @status_file = config.status_file
        load_status
      end
      
      def load_status
        @status = YAML.load_file(status_file) rescue {}
      end
      
      def save_status
        File.open(status_file, 'w') { |f| f << status.to_yaml }
      end
      
      def set(group, key, value)
        status[group] = {} unless status[group]
        status[group][key] = value
        status[group]['last_updated'] = Time.now.to_s
        save_status
      end
      
      def [](group)
        status[group]
      end
      
      private
      
      attr_accessor :status_file
      attr_accessor :status
      
    end
  end
end