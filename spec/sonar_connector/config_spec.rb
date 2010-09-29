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
    
    it "should set email settings" do
      @config.email_settings.should be_instance_of(Hash)
    end
  end
  
  describe "associate_connector_dependencies!" do
    before do
      @config = Sonar::Connector::Config.load(valid_config_filename)
      @connector_klass = new_anon_class(Sonar::Connector::Base, "MyConnector")
    end
    
    def connector_with_name_and_source(name, source_name)
      @connector_klass.new({'class'=>'MyConnector', 'name'=>name, 'source_connectors'=>[source_name], 'repeat_delay'=> 10}, @config)
    end
    
    it "should associate a source connector" do
      connector1 = connector_with_name_and_source 'c1', nil
      connector2 = connector_with_name_and_source 'c2', 'c1'
      
      @config.send :associate_connector_dependencies!, [connector1, connector2]
      
      connector1.source_connectors.should be_nil
      connector2.source_connectors.should == [connector1]
    end

    it "should associate multiple source connectors correctly" do
      connector1 = connector_with_name_and_source 'c1', nil
      connector2 = connector_with_name_and_source 'c2', 'c1'
      connector3 = connector_with_name_and_source 'c3', nil
      connector4 = connector_with_name_and_source 'c4', 'c3'
      
      @config.send :associate_connector_dependencies!, [connector1, connector2, connector3, connector4]
      
      connector1.source_connectors.should be_nil
      connector2.source_connectors.should == [connector1]
      connector3.source_connectors.should be_nil
      connector4.source_connectors.should == [connector3]
    end
    
    it "should raise error when source_connector doesn't exist" do
      connector1 = connector_with_name_and_source 'c1', 'invalid_connector_name'
      lambda{
        @config.send :associate_connector_dependencies!, [connector1]
      }.should raise_error(Sonar::Connector::InvalidConfig, /no such connector name is defined/)
    end
    
    it "should raise error if connector is set as its own source" do
      connector1 = connector_with_name_and_source 'c1', 'c1'
      lambda{
        @config.send :associate_connector_dependencies!, [connector1]
      }.should raise_error(Sonar::Connector::InvalidConfig, /cannot have itself as a/)
    end
    
  end
end
