module Sonar
  module Connector
    class InvalidConfig < RuntimeError; end
    
    class Config

      # base params
      attr_reader :base_dir
      attr_reader :log_dir
      attr_reader :connectors_dir
      attr_reader :controller_log_file
      attr_reader :connectors
      attr_reader :email_settings
      
      # configurable: logger params
      attr_reader :log_level
      attr_reader :log_file_max_size
      attr_reader :log_files_to_keep
      
      # Entry-point for creating and setting the CONFIG instance.
      # Give it a path to the JSON settings file and it'll do the rest.
      def self.load(config_file)
        config = Config.new(config_file).parse
        Sonar::Connector.const_set("CONFIG", config)
      end
      
      # Helper method to read and parse JSON file from disk. Abstracted for testing purposes.
      def self.read_json_file(config_file)
        JSON.parse IO.read(config_file)
      end
      
      def initialize(config_file)
        @config_file = config_file
      end
      
      def parse
        @raw_config = Config.read_json_file(config_file)
        
        # extract the core config params
        @base_dir = parse_base_dir @raw_config["base_dir"]
        @log_dir = File.join @base_dir, 'log'
        @connectors_dir = File.join @base_dir, 'var'
        @controller_log_file = File.join @log_dir, 'controller.log'
        @log_level = parse_log_level @raw_config["log_level"]
        @log_file_max_size = parse_log_file_max_size @raw_config["log_file_max_size"]
        @log_files_to_keep = parse_log_files_to_keep @raw_config["log_files_to_keep"]
        @email_settings = parse_email_settings @raw_config["email_settings"]
        
        # extract each connector, locate its class and attempt to parse its config
        @connectors = parse_connectors @raw_config["connectors"]
        
        self
      rescue JSON::ParserError => e
        raise InvalidConfig.new("Config file #{config_file} is not in a valid JSON format. Please check the contents carefully. This is the exact error: \n#{e.message}")
      end

      private
      
      attr_reader :config_file
      attr_reader :raw_config
      
      def parse_base_dir(base_dir)
        d = base_dir.blank? ? File.dirname(File.dirname(@config_file)) : base_dir
        raise InvalidConfig.new("#{d} not a valid directory") unless File.directory?(d)
        d
      end
      
      def parse_log_level(log_level)
        raise InvalidConfig.new("Config option 'log_level' is a required parameter.") if log_level.blank?
        valid_log_levels = ["debug", "info", "warn", "error", "fatal"]
        raise InvalidConfig.new("unknown log_level #{log_level}") unless valid_log_levels.include?(log_level)
        Logger.const_get log_level.upcase
      end
      
      def parse_log_file_max_size(log_file_max_size)
        raise InvalidConfig.new("invalid log_file_max_size #{log_file_max_size}") if !log_file_max_size.blank? && log_file_max_size.to_i == 0
        log_file_max_size.blank? ? 10*1024*1024 : log_file_max_size.to_i*1024*1024
      end

      def parse_log_files_to_keep(log_files_to_keep)
        raise InvalidConfig.new("invalid log_files_to_keep #{log_files_to_keep}") if !log_files_to_keep.blank? && log_files_to_keep.to_i == 0
        log_files_to_keep.blank? ? 10 : log_files_to_keep.to_i
      end
      
      def parse_email_settings(settings)
        ActionMailer::Base.perform_deliveries = settings["perform_deliveries"]
        ActionMailer::Base.delivery_method = settings["delivery_method"].to_sym
        ActionMailer::Base.raise_delivery_errors = settings["raise_delivery_errors"]
        
        # ActionMailer needs the smtp and sendmail settings hashes to have symbols for keys
        ActionMailer::Base.smtp_settings  = symbolise_hash_keys settings["smtp_settings"]
        ActionMailer::Base.sendmail_settings = symbolise_hash_keys settings["sendmail_settings"]
        
        ActionMailer::Base.save_emails_to_disk = settings["save_emails_to_disk"]
        ActionMailer::Base.email_output_dir = File.join @base_dir, 'sent_administrator_emails'
        ActionMailer::Base.safe_recipients = [:all]
        settings
      end
      
      def parse_connectors(connectors_config)
        raise InvalidConfig.new("Connector parameter must be an array and cannot be empty") unless connectors_config.instance_of?(Array) && !connectors_config.empty?
        
        c = []
        connectors_config.each do |config|
          c << parse_connector(config)
        end
        
        raise InvalidConfig.new("Connector names must be unique. You supplied: #{c.map(&:name).inspect}") if c.map(&:name).uniq.size != c.size
        c
      end
      
      def parse_connector(config)
        # first see if this class is already loaded
        type = config["type"]
        raise InvalidConfig.new("Error with connector settings '#{config.inspect}': parameter 'type' must be specified") if type.blank?
        
        klass = type.camelize.constantize rescue nil
        
        # try in the Sonar::Connector module space
        klass = ("sonar/connector/"+type).camelize.constantize rescue nil
        
        # try again with require
        unless klass
          require type rescue nil
          klass = type.camelize.constantize rescue nil
        end
        
        # give up if it still doesn't exist
        raise InvalidConfig.new("Error with connector '#{type}': could not find a class for it called #{type.camelize}") unless klass
        
        # sanity-check that the connector class subclasses the base
        raise InvalidConfig.new("Connector class #{klass.name} must subclass Sonar::Connector::Base") unless klass.ancestors.include?(Sonar::Connector::Base)
        klass.new(config, self)
      end
      
      def symbolise_hash_keys(hash)
        return nil unless hash
        hash.keys.inject({}){|acc, k| acc[k.to_sym] = hash[k]; acc}
      end
      
    end
  end
end

