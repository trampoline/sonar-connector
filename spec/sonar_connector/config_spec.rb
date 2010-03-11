require 'spec_helper'

describe Sonar::Connector::Config do
  
  before do
    setup_valid_config_file
  end
  
  describe "self.load" do
    before do
      @config = Sonar::Connector::Config.load(valid_config_filename)
    end
    
    it "should return config" do
      @config.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should set CONFIG constant" do
      Sonar::Connector::CONFIG.should == @config
    end
    
  end
  
  describe "parse" do
    before do
      @config = Sonar::Connector::Config.new(valid_config_filename).parse
    end
    
    it "should return the config instance" do
      @config.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should symbolize log_level" do
      @config_options["log_level"] = "error"
      @config = Sonar::Connector::Config.new(valid_config_filename).parse
      @config.log_level.should == Logger::ERROR
    end
    
  end
end
