require 'spec_helper'

describe Sonar::Connector::Base do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @connector_klass = new_anon_class(Sonar::Connector::Base, "MyConnector") {}
    @config = {'name'=>'foo', 'repeat_delay'=> 10}
    @connector = @connector_klass.new(@config, @base_config)
  end
  
  describe "initialize" do
    it "should set name" do
      c = @connector_klass.new(@config, @base_config)
      c.name.should == 'foo'
    end
    
    it "should require repeat delay of at least 1.0 second" do
      @config['repeat_delay'] = nil
      lambda{
        @connector_klass.new(@config, @base_config)
      }.should raise_error(Sonar::Connector::InvalidConfig)
      
      @config['repeat_delay'] = 0
      lambda{
        @connector_klass.new(@config, @base_config)
      }.should raise_error(Sonar::Connector::InvalidConfig)
      
      @config['repeat_delay'] = 0.9
      lambda{
        @connector_klass.new(@config, @base_config)
      }.should raise_error(Sonar::Connector::InvalidConfig)
    end
    
    it "should set blank state hash" do
      c = @connector_klass.new(@config, @base_config)
      c.state.should == {}
    end
    
    it "should parse config" do
      mock.instance_of(@connector_klass).parse(@config){}
      @connector_klass.new(@config, @base_config)
    end
    
    it "should load state after parsing config so as not to overwrite any state" do
      @connector_klass = new_anon_class(Sonar::Connector::Base, "MyConnector"){
        def parse(config)
          state[:foo] = 'default state value from config'
        end
      }
      
      mock.instance_of(@connector_klass).read_state(){
        {:foo => 'overridden by state'}
      }
      
      c = @connector_klass.new(@config, @base_config)
      c.state[:foo].should == 'overridden by state'
    end
  end
  
  describe "read_state" do
    it "should return empty hash if the file doesn't exist" do
      File.exists?(@connector.send :state_file).should be_false
      @connector.read_state.should == {}
    end
    
    it "should load hash from yaml file" do
      mock(File).exist?(@connector.send :state_file){true}
      mock(YAML).load_file(@connector.send :state_file) { {:foo=>:bar} }
      @connector.read_state.should == {:foo=>:bar}
    end
    
    it "should log error and return empty hash if the yaml read throws error" do
      mock(File).exist?(@connector.send :state_file){true}
      mock(YAML).load_file(@connector.send :state_file) { raise "foo" }
      mock(@connector.log).error(anything) do |param|
        param.should match(/error loading/)
      end
      @connector.read_state.should == {}
    end
    
  end
  
  describe "load_state" do
    it "should merge keys" do
      @connector.state[:foo] = :bar
      @connector.state[:baz] = 'old value'
      
      @connector.save_state
      
      @connector.state[:baz] = 'new value'
      
      @connector.load_state
      
      @connector.state[:foo].should == :bar
      @connector.state[:baz] = 'old value'
    end
  end
  
  describe "save_state" do
    it "should save state to yaml" do
      @connector.state[:foo] = :bar
      @connector.save_state
      @connector.state[:foo] = nil
      @connector.load_state
      @connector.state[:foo].should == :bar
    end
  end
  
end