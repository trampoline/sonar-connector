require 'spec_helper'

describe Sonar::Connector::Status do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @status = Sonar::Connector::Status.new(@base_config)
  end
  
  describe "initialize" do
    it "should load status" do
      @status.send(:status).should be_instance_of(Hash)
    end
  end
  
  describe "[]" do
    it "should access the group" do
      @status.set("group", "key", "value")
      @status["group"]["key"].should == "value"
    end
  end 
  
  describe "[]=" do
    it "should set the group" do
      @status["group"].should be_nil
      @status["group"] = {"key" => "value"}
      @status["group"]["key"].should == "value"
    end
  end
  
  describe "load_status" do
    it "should load yml file if it exists" do
      mock(YAML).load_file(@base_config.status_file){ {:foo=>:bar} }
      
      @status[:foo].should be_nil
      @status.load_status
      @status[:foo].should == :bar
    end
  end
  
  describe "save_status" do
    it "should save serialised status" do
      @status.set "group", "key", "value"
      @status.save_status
      @status.send(:status=, {})
      
      @status["group"].should be_nil
      @status.load_status
      @status["group"]["key"].should == "value"
    end
  end
  
  describe "set" do
    it "should initialize the group hash if it doesn't exist" do
      @status["group"] = nil
      @status.set "group", "key", "value"
      @status["group"].should be_instance_of(Hash)
    end
    
    it "should set key and value" do
      @status["group"].should be_nil
      @status.set("group", "key", "value")
      @status["group"]["key"].should == "value"
    end
    
    it "should update the timestamp" do
      now = Time.now
      stub(Time).now{now}
      @status.set("group", "key", "value")
      @status["group"]["last_updated"] = nil
      @status["group"]["last_updated"].should be_nil
      
      @status.set("group", "key", "value")
      @status["group"]["last_updated"].should == now.to_s
    end
  end
    
end