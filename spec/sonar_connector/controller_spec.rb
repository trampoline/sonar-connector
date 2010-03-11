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
  
end
