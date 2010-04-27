require 'spec_helper'

describe Sonar::Connector::Base do
  before do
    setup_valid_config_file
    @base_config = Sonar::Connector::Config.load(valid_config_filename)
    @connector_klass = new_anon_class(Sonar::Connector::Base, "MyConnector") {}
    @config = {'class'=>'MyConnector', 'name'=>'foo', 'repeat_delay'=> 10}
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
  
  describe "create_filestores" do
    it "should create filestores for working, error and complete" do
      stub(Sonar::Connector::FileStore).new
      @connector.create_filestores
      Sonar::Connector::FileStore.should have_received.new(File.join @connector.connector_dir, "working")
      Sonar::Connector::FileStore.should have_received.new(File.join @connector.connector_dir, "error")
      Sonar::Connector::FileStore.should have_received.new(File.join @connector.connector_dir, "complete")
    end
  end
  
  describe "start" do
    before do
      @connector = new_anon_class(Sonar::Connector::Base, "MyConnector"){
        def action
          true
        end
      }.new(@config, @base_config)
      @queue = Queue.new
      stub(@connector).sleep_for(anything)
      
      # don't switch to log file, but don't close stdout either
      mock(@connector).switch_to_log_file
    end
    
    it "should peform the action once per iteration" do
      mock(@connector) do
        run(){true}
        run(){true}
        run(){false}
      end
      
      mock(@connector).action.times(2)
      
      @connector.start(@queue)
    end
    
    it "should catch uncaught exceptions from the action" do
      mock(@connector) do
        run(){true}
        run(){true}
        run(){false}
      end
      
      mock(@connector) do
        action(){raise "uncaught exception"}
        action(){true}
      end
      
      @connector.start(@queue)
    end
    
    it "should terminate on ThreadTerminator exception" do
      stub(@connector).run{true}
      mock(@connector).action(){raise Sonar::Connector::ThreadTerminator.new}
      @connector.start(@queue)
    end
    
    it "should queue status update and disk usage commands on successful action" do
      mock(@connector) do
        run(){true}
        run(){true}
        run(){false}
      end
      
      stub(Sonar::Connector::UpdateStatusCommand).new
      stub(Sonar::Connector::UpdateDiskUsageCommand).new
      stub(@queue, :<<)
      
      @connector.start(@queue)
      
      Sonar::Connector::UpdateStatusCommand.should have_received.new(anything, 'last_action', Sonar::Connector::ACTION_OK).times(2)
      Sonar::Connector::UpdateDiskUsageCommand.should have_received.new(anything).times(2)
      @queue.should have_received(:<<).with(anything).times(10) # 5x commands queued on 2x action invocations
    end
    
    it "should queue error status update on unhandled action error" do
      mock(@connector) do
        run(){true}
        run(){false}
      end
      
      mock(@connector) do
        action(){raise "uncaught exception"}
      end
      
      command = Object.new
      mock(Sonar::Connector::UpdateStatusCommand).new(anything, 'last_action', Sonar::Connector::ACTION_FAILED).times(1){command}
      mock(@queue, :<<).with(command).times(1)
      @connector.start(@queue)
    end
    
  end
  
end