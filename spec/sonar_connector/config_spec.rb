require 'spec_helper'

describe Sonar::Connector::Config do
  
  before do
    @config = {
      "log_level" => "warn",
      "connectors" => [
        "name" => "dummy_connector_1",
        "type" => "dummy_connector",
        "repeat_delay" => 10
      ]
    }
    @config_file_contents = @config.to_json
    mock(IO).read('config_file'){@config_file_contents}
  end
  
  describe "self.read_config" do
    def new_config
      Sonar::Connector::Config.read_config('config_file')
    end
    
    it "should return config" do
      new_config.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should set CONFIG constant" do
      Sonar::Connector.send(:remove_const, "CONFIG") if defined?(Sonar::Connector::CONFIG)
      defined?(Sonar::Connector::CONFIG).should be_false
      config = new_config
      Sonar::Connector::CONFIG.should == config
    end
    
  end
  
  describe "parse" do
    def create_and_parse
      Sonar::Connector::Config.new('config_file').parse
    end
    
    it "should return the config instance" do
      create_and_parse.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should symbolize log_level" do
      @config["log_level"] = "error"
      @config_file_contents = @config.to_json
      create_and_parse.log_level.should == Logger::ERROR
    end
    
  end
end
