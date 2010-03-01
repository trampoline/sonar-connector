module Sonar
  module Connector
    class Base
      
      attr_reader :name, :connector_dir, :log, :state, :repeat_delay, :queue
      
      def initialize(connector_config, base_config)
        @name = connector_config["name"]
        @raw_connector_config = connector_config
        
        # Creat logger and inherit the logger settings from the base controller config
        @log_file = File.join(base_config.log_dir, "#{connector_config["type"]}_#{@name}.log")
        @log = Logger.new(@log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
        @log.level = base_config.log_level
        
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay is missing or blank") if connector_config["repeat_delay"].blank?
        @repeat_delay = connector_config["repeat_delay"].to_i
        @connector_dir = File.join(base_config.connectors_dir, @name)
        
        FileUtils.mkdir_p(@connector_dir) unless File.directory?(@connector_dir)
        
        parse(connector_config)
        load_state
      end
      
      def load_state
        log.info "loading state"
        @state = {}
      end
      
      def save_state
        log.info "saving state"
      end
      
      
      def run(queue)
        @queue = queue
        load_state
        while true
          begin
            self.action
            save_state
            sleep repeat_delay
          rescue Exception => e
            log.error("Connector '#{name} blew out with an unhandled exception: \n#{e.message}\n#{e.backtrace.join("\n")}")
            log.info("restarting connector after exception in 5 seconds.")
            sleep 5
          end
        end
        
      end
      
      def parse(config)
        raise RuntimeError.new("class #{self.class} must implement #parse method")
      end
      
      private
      
      attr_reader :raw_connector_config
      
    end
  end
end