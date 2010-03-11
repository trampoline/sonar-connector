$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sonar_connector'
require 'spec'
require 'spec/autorun'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with :rr
  
  config.prepend_before(:each) do
    
    def valid_config_filename
      "path to a valid config file"
    end
    
    def setup_valid_config_file
      @config_options = {
        "log_level" => "warn",
        "connectors" => [
          "name" => "dummy_connector_1",
          "type" => "dummy_connector",
          "repeat_delay" => 10
        ]
      }
      stub(Sonar::Connector::Config).read_json_file(valid_config_filename){@config_options}
      Sonar::Connector.send(:remove_const, "CONFIG") if defined?(Sonar::Connector::CONFIG)
    end
    
  end
end
