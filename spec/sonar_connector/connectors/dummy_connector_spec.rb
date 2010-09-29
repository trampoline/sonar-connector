require 'spec_helper'

describe Sonar::Connector::DummyConnector do
  before do
    setup_valid_config_file
  end
  
  describe "action" do
    before do
      @base_config = Sonar::Connector::Config.load(valid_config_filename)
      @config = {'name'=>'foo', 'repeat_delay'=> 5}
      @connector = Sonar::Connector::DummyConnector.new(@config, @base_config)
    end
    
    it "should log a quirky debug message" do
      mock(@connector.log).debug(anything) do |param|
        param.should match(/mumbled incoherently to itself/)
      end
      @connector.action
    end
  end
end