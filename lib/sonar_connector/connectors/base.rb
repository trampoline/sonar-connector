module Sonar
  module Connector
    class Base
      
      # every connector has a unique name
      attr_reader :name
      
      # each connector instance has a working dir for its state and files
      attr_reader :connector_dir
      
      # log instance
      attr_reader :log
      
      # state hash that is serialized and persisted to disk every cycle of the run loop
      attr_reader :state
      
      # repeat delay which is waited out on each cycle of the run loop
      attr_reader :repeat_delay
      
      # central command queue for sending messages back to the controller
      attr_reader :queue
      
      def initialize(connector_config, base_config)
        @name = connector_config["name"]
        @raw_connector_config = connector_config
        
        # Creat logger and inherit the logger settings from the base controller config
        @log_file = File.join(base_config.log_dir, "#{connector_config["type"]}_#{@name}.log")
        @log = Logger.new(@log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
        @log.level = base_config.log_level
        
        # every connector instance must set the repeat delay
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay is missing or blank") if connector_config["repeat_delay"].blank?
        @repeat_delay = connector_config["repeat_delay"].to_i
        
        @connector_dir = File.join(base_config.connectors_dir, @name)
        FileUtils.mkdir_p(@connector_dir) unless File.directory?(@connector_dir)
        
        parse connector_config
        load_state
      end
      
      def load_state
        
        log.info "loading state"
        @state = {}
      end
      
      def save_state
        log.info "saving state"
      end
      
      # the main run loop that every connector executes indefinitely.
      def run(queue)
        @queue = queue
        load_state
        while true
          begin
            self.action
            save_state
            sleep repeat_delay
          rescue Exception => e
            log.error "Connector '#{name} raised an unhandled exception: \n#{e.message}\n#{e.backtrace.join("\n")}"
            log.info "Connector blew up with an exception - waiting 5 seconds before retrying."
            sleep 5
            retry
          end
        end
      end
      
      # All connector subclasses must implement the parse method.
      def parse(config)
        raise RuntimeError.new("class #{self.class} must implement #parse method")
      end
      
      private
      
      attr_reader :raw_connector_config
      
    end
  end
end