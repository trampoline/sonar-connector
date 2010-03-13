$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sonar_connector'
require 'spec'
require 'spec/autorun'
require 'rr'

Spec::Runner.configure do |config|
  config.mock_with :rr
  
  config.prepend_before(:each) do
    
    def base_dir
      "/tmp/sonar-connector/"
    end
    
    def valid_config_filename
      "path to a valid config file"
    end
    
    def setup_valid_config_file
      @config_options = {
        "log_level" => "warn",
        "base_dir" => base_dir,
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
