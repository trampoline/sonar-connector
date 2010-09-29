require 'spec_helper'

describe Sonar::Connector::Controller do
  
  before do
    setup_valid_config_file
  end
  
  describe "new" do
    before do
      @controller = Sonar::Connector::Controller.new(valid_config_filename)
    end
    
    it "should assign a logger" do
      @controller.log.should be_instance_of(Logger)
    end
    
    it "should assign a queue" do
      @controller.queue.should be_instance_of(Queue)
    end
  end
  
  describe "start" do
    before do
      
      # Add another connector so we have two in total
      @config_options["connectors"] << {
        "class" => "Sonar::Connector::DummyConnector",
        "name" => "dummy2",
        "repeat_delay" => 10
      }
      
      @controller = Sonar::Connector::Controller.new(valid_config_filename)
      @controller.connectors.count.should == 2
    end
    
    it "should invoke a thread for each connector plus one for the consumer" do
      t = Object.new
      stub(t).join(){true}
      mock(@controller).endless_sleep(){nil}
      mock(Thread).new().times(3){t} # once per conector and one for the consumer
      @controller.start
    end
  end

end
