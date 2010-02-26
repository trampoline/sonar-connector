require 'spec_helper'

describe Sonar::Connector::Config do
  
  describe "self.read_config" do
    before do
      @config_file_contents = <<-JAVASCRIPT
        {
          "log_level": "warn"
        }
      JAVASCRIPT
      mock(IO).read('config_file'){@config_file_contents}
    end
    
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
  
  describe "parse!" do
    
    before do
      @raw_config = {
        "log_level" => "warn"
      }
      mock(IO).read('config_file'){@raw_config.to_json}
    end
    
    def create_and_parse
      Sonar::Connector::Config.new('config_file').parse!
    end
    
    it "should return the config instance" do
      create_and_parse.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should symbolize log_level" do
      @raw_config["log_level"] = "error"
      create_and_parse.log_level.should == "error"
    end
    
  end
end
