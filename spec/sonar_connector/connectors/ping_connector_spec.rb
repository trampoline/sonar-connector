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
      @config = {'name'=>'foo', 'repeat_delay'=> 5, 'host'=>'google.com'}
      @connector = Sonar::Connector::PingConnector.new(@config, @base_config)
      @connector.state[:consecutive_errors].should == 0
      @queue = Queue.new
      @connector.instance_variable_set("@queue", @queue)
    end
    
    it "should increment consecutive_errors count if host is unpingable" do
      ping = Object.new
      mock(ping).ping?{false}
      mock(Net::Ping::External).new(anything, anything, anything){ping}
      lambda{
        @connector.action
      }.should change{@connector.state[:consecutive_errors]}.by(1)
    end
    
    it "should reset consecutive_errors count if host is pingable" do
      @connector.state[:consecutive_errors] = 10
      ping = Object.new
      mock(ping).ping?{true}
      mock(Net::Ping::External).new(anything, anything, anything){ping}
      @connector.action
      @connector.state[:consecutive_errors] = 0
    end
    
    it "should queue an admin email if the host is unpingable after max retries" do
      ping = Object.new
      stub(ping).ping?{false}
      stub(Net::Ping::External).new(anything, anything, anything){ping}
      
      mock(@queue).push(anything) do |param|
        param.should be_instance_of(Sonar::Connector::SendAdminEmailCommand)
      end
      
      (@connector.retry_count+1).times do
        @connector.action
      end
    end
    
  end
  
end