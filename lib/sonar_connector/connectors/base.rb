module Sonar
  module Connector
    class Base
      
      # every connector has a unique name
      attr_reader :name
      
      # Connector-specific config hash
      attr_reader :raw_config
      
      # each connector instance has a working dir for its state and files
      attr_reader :connector_dir
      
      # logger instance
      attr_reader :log
      
      # state hash that is serialized and persisted to disk every cycle of the run loop
      attr_reader :state
      
      # repeat delay which is waited out on each cycle of the run loop
      attr_reader :repeat_delay
      
      # central command queue for sending messages back to the controller
      attr_reader :queue
      
      # run loop flag
      attr_reader :run
      
      # connector FileStore
      attr_reader :filestore
      
      # Associated connector that provides source data via the file system
      attr_reader :source_connector
      
      def initialize(connector_config, base_config)
        @base_config = base_config
        @raw_config = connector_config
        
        @name = connector_config["name"]
        
        # Create STDOUT logger and inherit the logger settings from the base controller config
        @log_file = File.join base_config.log_dir, "connector_#{@name}.log"
        @log = Sonar::Connector::Utils.stdout_logger base_config
        
        # every connector instance must set the repeat delay
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay is missing or blank") if connector_config["repeat_delay"].blank?
        @repeat_delay = connector_config["repeat_delay"].to_i
        raise InvalidConfig.new("Connector '#{@name}': repeat_delay must be >= 1 second") if @repeat_delay < 1
        
        @connector_dir = File.join(base_config.connectors_dir, @name)
        FileUtils.mkdir_p(@connector_dir)
        @state_file = File.join(@connector_dir, "state.yml")
        
        # empty state hash which will get written to by parse, and then potentially over-written by load_state
        @state = {}

        @filestore = Sonar::Connector::FileStore.new(@connector_dir, :filestore, [:working, :error, :complete, :actions])

        parse connector_config
        load_state
        
        @run = true
      end
      
      # Logging defaults to use STDOUT. After initialization we need to switch the 
      # logger to use an output file.
      def switch_to_log_file
        @log = Sonar::Connector::Utils.disk_logger(log_file, base_config)
      end
      
      # Load the state hash from YAML file
      def load_state
        @state.merge! read_state
      end
      
      # Read state file
      def read_state
        s = {}
        s = YAML.load_file state_file if File.exist?(state_file)
        raise "State file did not contain a serialised hash." unless s.is_a?(Hash)
      rescue Exception => e
        log.error "Error loading #{state_file} so it was ignored. Original error: #{e.message}\n" + e.backtrace.join("\n")
      ensure 
        return s
      end
      
      # Save the state hash to a YAML file
      def save_state
        make_dir
        File.open(state_file, "w"){|f| f << state.to_yaml }
      end
      
      # Cleanup routine after connector shutdown
      def cleanup
      end
      
      # the main run loop that every connector executes indefinitely 
      # until Thread.raise is called on this instance.
      def start(queue)
        @queue = queue
        switch_to_log_file
        
        cleanup_old_action_filestores # in case we were interrupted mid-action
        cleanup # before we begin

        while run
          begin
            log.info "beginning action"

            in_action_context do
              action

              save_state
              log.info "finished action and saved state"
              
              log.info "working count: #{filestore.count(:working)}"
              log.info "error count: #{filestore.count(:error)}"
              log.info "complete count: #{filestore.count(:complete)}"
              
              queue << Sonar::Connector::UpdateStatusCommand.new(connector, 'last_action', Sonar::Connector::ACTION_OK)
              queue << Sonar::Connector::UpdateDiskUsageCommand.new(connector)
              queue << Sonar::Connector::UpdateStatusCommand.new(connector, 'working_count', filestore.count(:working))
              queue << Sonar::Connector::UpdateStatusCommand.new(connector, 'error_count', filestore.count(:error))
              queue << Sonar::Connector::UpdateStatusCommand.new(connector, 'complete_count', filestore.count(:complete))
            end
            sleep_for repeat_delay
            
          rescue ThreadTerminator
            break
            
          rescue Exception => e
            log.error "Connector '#{name} raised an unhandled exception: \n#{e.message}\n#{e.backtrace.join("\n")}"
            log.info "Connector blew up with an exception - waiting 5 seconds before retrying."
            queue << Sonar::Connector::UpdateStatusCommand.new(self, 'last_action', Sonar::Connector::ACTION_FAILED)
            sleep_for 5
          end
        end
        
        @run = false
        cleanup
        true
      end
      
      # Connector subclasses can overload the parse method.
      def parse(config)
        log.warn "Method #parse called on connector base class. Connector #{name} should define #parse method."
      end
      
      def to_s
        "#{self.class} '#{name}'"
      end
      alias :inspect :to_s
      
      private
      
      attr_reader :state_file, :base_config, :log_file
      attr_writer :source_connector
      
      def sleep_for(seconds=0)
        sleep seconds
      end
      
      def make_dir
        FileUtils.mkdir_p(@connector_dir) unless File.directory?(@connector_dir)
      end

      class ActionContext
        attr_reader :connector

        # action specific filestore
        attr_reader :filestore
        
        def initialize(connector, filestore)
          @connector = connector
          @filestore = filestore
        end

        def respond_to?(sym, include_private=false)
          self.respond_to?(sym, include_private) || connector.respond_to?(sym, include_private)
        end

        def method_missing(m,*args)
          connector.send(m, *args)
        end
      end

      def in_action_context(&proc)
        fs = create_action_filestore
        begin
          initialize_action_filestore(fs)
          context = ActionContext.new(self, fs)
          context.instance_eval(&proc)
        ensure
          finalize_action_filestore(fs)
        end
      end
      
      def create_action_filestore
        now = Time.new
        fs_name = now.strftime("action_%Y%m%d_%H%M%S_") + UUIDTools::UUID.timestamp_create.to_s.gsub('-','_')
        action_fs_root = filestore.area_path(:actions)
        FileStore.new(action_fs_root, fs_name, [:working, :error, :complete])
      end

      def initialize_action_filestore(fs)
        # grab any unfinished work for this action
        filestore.flip(:working, fs, :working)
        fs.scrub!(:working)
      end

      def finalize_action_filestore(fs)
        [:complete, :error, :working].each do |area|
          fs.scrub!(area)
          fs.flip(area, filestore, area)
        end
        fs.destroy!
      end

      def cleanup_old_action_filestores
        actionfs_root = filestore.area_path(:actions)
        
        Dir.foreach(actionfs_root) do |fs_name|
          if FileStore.valid_filestore_name(fs_name)
            fs = FileStore.new(actionfs_root, fs_name, [:working, :error, :complete])
            finalize_action_filestore(fs)
          end
        end
      end
    end
  end
end
