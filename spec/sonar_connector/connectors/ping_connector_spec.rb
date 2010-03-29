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
    
    it "should set consecutive_errors unless its set already" do
      pending
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
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