$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sonar_connector'
require 'spec'
require 'spec/autorun'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with :rr
  
  config.prepend_before(:each) do
    
    # This dir gets wiped after every spec run, so please - pretty please - 
    # don't change it to anything that you care about.
    def base_dir
      "/tmp/sonar-connector/"
    end
    
    # Note this path doesn't have to be real - it's just used to intercept calls 
    # to the stubbed read_json_file method on Config
    def valid_config_filename
      "path to a valid config file"
    end
    
    def setup_valid_config_file
      @config_options = {
        "log_level" => "error",
        "base_dir" => base_dir,
        "email_settings" => {
          "admin_sender" => "noreply@example.local",
          "admin_recipients" => ["admin@example.local"],
          "perform_deliveries" => true,
          "delivery_method" => "test",
          "raise_delivery_errors" => true,
          "save_emails_to_disk" => false
        },
        
        "connectors" => [
          "name" => "dummy_connector_1",
          "type" => "dummy_connector",
          "repeat_delay" => 10
        ]
      }
      stub(Sonar::Connector::Config).read_json_file(valid_config_filename){@config_options}
      Sonar::Connector.send(:remove_const, "CONFIG") if defined?(Sonar::Connector::CONFIG)
    end
    
    # This is slightly dangerous.
    FileUtils.rm_rf(base_dir) if File.directory?(base_dir)
    FileUtils.mkdir_p(base_dir)
  end
  
end


# Creates an anonmyous throw-away class of type=parent, with an additional
# proc for defining methods on the class. Tnx @mccraigmccraig :-)
def new_anon_class(parent, name="", &proc)
  klass = Class.new(parent)  
  mc = klass.instance_eval{ class << self ; self ; end }
  mc.send(:define_method, :to_s) {name}
  klass.class_eval(&proc) if proc
  klass
end
