require 'spec_helper'

describe Sonar::Connector::Config do
  
  describe "self.create" do
    before do
      @config_file = <<-JAVASCRIPT
      {
        "log_level": "warn"
      }
      JAVASCRIPT
      mock(IO).read('filename'){@config_file}
    end
    
    it "should return config" do
      c = Sonar::Connector::Config.create('filename')
      c.should be_instance_of(Sonar::Connector::Config)
    end
    
    it "should set CONFIG constant" do
      # yes i know that blatting the constant like this is evil
      Sonar::Connector.send(:remove_const, "CONFIG") if defined?(Sonar::Connector::CONFIG)
      defined?(Sonar::Connector::CONFIG).should be_false
      Sonar::Connector::Config.create('filename')
      Sonar::Connector::CONFIG.should be_instance_of(Sonar::Connector::Config)
    end
  end
  
  describe "parse" do
    
    before do
      @raw_config = {
        "log_level" => "warn"
      }
    end
    
    it "should set log_level" do
      pending
    end
    
  end
end
