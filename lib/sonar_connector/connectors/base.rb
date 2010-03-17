module Sonar
  module Connector
    class Base
      
      ##
      # every connector has a unique name
      attr_reader :name
      
      ##
      # each connector instance has a working dir for its state and files
      attr_reader :connector_dir
      
      ##
      # logger instance
      attr_reader :log
      
      ##
      # state hash that is serialized and persisted to disk every cycle of the run loop
      attr_reader :state
      
      ##
      # repeat delay which is waited out on each cycle of the run loop
      attr_reader :repeat_delay
      
      ##
      # central command queue for sending messages back to the controller
      attr_reader :queue
      
      def initialize(connector_config, base_config)
        @base_config = base_config
        @raw_connector_config = connector_config
        
        @name = connector_config["name"]
        
        # Create STDOUT logger and inherit the logger settings from the base controller config
        @log_file = File.join(base_config.log_dir, "#{connector_config["type"]}_#{@name}.log")
        @log = Logger.new(STDOUT)
        @log.level = base_config.log_level
        
        # every connector instance must set the repeat delay
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay is missing or blank") if connector_config["repeat_delay"].blank?
        @repeat_delay = connector_config["repeat_delay"].to_i
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay must be >= 1 second") if @repeat_delay < 1
        
        @connector_dir = File.join(base_config.connectors_dir, @name)
        @state_file = File.join(@connector_dir, "state.yml")
        @state = {}
        
        parse connector_config
      end
      
      ##
      # Logging defaults to use STDOUT. After initialization we need to switch the 
      # logger to use an output file.
      def switch_to_log_file
        @log = Logger.new(@log_file, base_config.log_files_to_keep, base_config.log_file_max_size)
      end
      
      ## 
      # Load @state variable from the YAML state file
      def load_state
        if File.exists? @state_file
          @state = YAML.load_file @state_file
          raise "State file did not contain a serialised hash." unless @state.is_a?(Hash)
          log.info "Loaded state file #{@state_file}"
        else
          save_state
          log.info "Created new state file #{@state_file}"
        end
      rescue Exception => e
        @state = {}
        log.error "Error loading #{@state_file} so it was ignored and the internal connector state was reset. Original error: #{e.message}"
      end
      
      ##
      # Save the @state to a YAML file
      def save_state
        File.open(@state_file, "w"){|f| f << state.to_yaml }
        log.info "saved state to #{@state_file}"
      end
      
      ##
      # the main run loop that every connector executes indefinitely 
      # until stop! called on the connector instance.
      def run(queue)
        @queue = queue
        
        FileUtils.mkdir_p(@connector_dir) unless File.directory?(@connector_dir)
        switch_to_log_file
        load_state
        
        while !stop?
          begin
            self.action
            save_state
            
            # break sleep time into 0.1 second chunks in order to exit the run loop
            # if this connector is asked to stop during the sleep cycle. 
            count_sleep_sections = repeat_delay / 0.1
            count_sleep_sections.to_i.times do 
              return if stop?
              sleep(0.1)
            end
            
          rescue Exception => e
            log.error "Connector '#{name} raised an unhandled exception: \n#{e.message}\n#{e.backtrace.join("\n")}"
            log.info "Connector blew up with an exception - waiting 5 seconds before retrying."
            sleep 5
            retry
          end
        end
      end
      
      def stop!
        @stop = true
      end
      
      def stop?
        @stop
      end
      
      ##
      # Connector subclasses can overload the parse method.
      def parse(config)
      end
      
      private
      
      attr_reader :raw_connector_config, :state_file, :base_config
      
    end
  end
end