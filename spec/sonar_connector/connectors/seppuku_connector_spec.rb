require 'spec_helper'

describe Sonar::Connector::SeppukuConnector do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @config = {'name'=>'foo', 'repeat_delay'=> 5}
  end
  
  describe "parse" do
    it "should set up a run counter" do
      @connector = Sonar::Connector::SeppukuConnector.new(@config, @base_config)
      @connector.run_count.should == 0
    end
  end
  
  describe "action" do
    before do
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