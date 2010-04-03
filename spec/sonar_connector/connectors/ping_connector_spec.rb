require 'spec_helper'

describe Sonar::Connector::PingConnector do
  before do
    setup_valid_config_file
  end
  
  describe "parse" do
    before do
      @base_config = Sonar::Connector::Config.load(valid_config_filename)
      @config = {'name'=>'foo', 'repeat_delay'=> 1, 'host'=>'google.com'}
    end
    
    it "should set host and default port" do
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.host.should == 'google.com'
      @connector.port.should == 80
    end
    
    it "should set port" do
      @config.merge!({'port'=>8088})
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.port.should == 8088
    end
    
    it "should set retry count" do
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.retry_count.should == 4
    end
    
    it "should set consecutive_errors unless if its not set already" do
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.state[:consecutive_errors].should == 0
    end
    
    it "should not set consecutive_errors if it's already in state" do
      mock(File).exist?(is_a String){true}
      mock(YAML).load_file(is_a String){ {:consecutive_errors=> 5} }
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.state[:consecutive_errors].should == 5
    end
  end
  
  describe "action" do
    before do
      @base_config = Sonar::Connector::Config.load(valid_config_filename)
      @config = {'name'=>'foo', 'repeat_delay'=> 1, 'host'=>'google.com'}
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
    end
    
  end
  
end