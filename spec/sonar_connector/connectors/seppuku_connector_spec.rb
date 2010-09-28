require 'spec_helper'

describe Sonar::Connector::SeppukuConnector do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @config = {'name'=>'foo', 'repeat_delay'=> 5}
  end
  
  describe "parse" do
    it "should set enabled to false if not present in config" do
      @config["enabled"].should be_blank
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @connector.enabled.should be_false
    end
    
    it "should set enabled to false if anything but true in config" do
      @config["enabled"] = 'true'
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @connector.enabled.should be_false
    end
    
    it "should set enabled to true if true in config" do
      @config["enabled"] = true
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @connector.enabled.should be_true
    end
    
    it "should set up a run counter" do
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @connector.run_count.should == 0
    end
  end
  
  describe "action" do
    before do
      @config["enabled"] = true
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @queue = []
      stub(@connector).queue{@queue}
    end
    
    it "should not issue seppuku command on 1st execution" do
      stub(Sonar::Connector::CommitSeppukuCommand).new
      @connector.action
      Sonar::Connector::CommitSeppukuCommand.should_not have_received.new
    end
    
    it "should issue seppuku command on 2nd execution" do
      stub(Sonar::Connector::CommitSeppukuCommand).new
      @connector.action
      @connector.action
      Sonar::Connector::CommitSeppukuCommand.should have_received.new
    end
  end
end