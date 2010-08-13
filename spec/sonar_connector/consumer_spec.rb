require 'spec_helper'

describe Sonar::Connector::Consumer do
  
  describe Sonar::Connector::ExecutionContext do
    before do
      @log = Object.new
      @status = Object.new
    end
    
    describe "initialize" do
      it "should set logger" do
        ec = Sonar::Connector::ExecutionContext.new(:log=>@log)
        ec.log.should == @log
      end
      
      it "should set status" do
        ec = Sonar::Connector::ExecutionContext.new(:status=>@status)
        ec.status.should == @status
      end
    end
  end
  
  describe "watch" do
    
    # create a new anonymous Sonar::Connector::Command descendant class
    def new_command_class(name)
      new_anon_class(Sonar::Connector::Command, name){
        def initialize(message)
          l = lambda do
            log.info message
          end
          super(l)
        end
      }
    end
    
    before do
      setup_valid_config_file
      @controller = Sonar::Connector::Controller.new(valid_config_filename)
      @consumer = Sonar::Connector::Consumer.new(@controller.config)
      @kommand = new_command_class("DummyCommand")
      @queue = Queue.new
    end
    
    it "should execute items on the queue" do
      k1 = @kommand.new("some message")
      k2 = @kommand.new("another message")
      
      mock(k1).execute(anything)
      mock(k2).execute(anything)
      
      @queue << k1
      @queue << k2
      
      # set up the run order
      mock(@consumer) do
        run(){true}
        run(){true}
        run(){false}
      end
      
      @consumer.prepare(@queue)
      @consumer.watch
    end
    
    it "should handle uncaught exceptions thrown by a command" do
      k1 = @kommand.new("some message")
      k2 = @kommand.new("another message")
      
      mock(k1).execute(anything){
        raise "command raised an uncaught exception"
      }
      mock(k2).execute(anything)
      
      @queue << k1
      @queue << k2
      
      # set up the run order
      mock(@consumer) do
        run(){true}
        run(){true}
        run(){false}
      end
      
      @consumer.prepare(@queue)
      @consumer.watch
    end
    
    it "should terminate on ThreadTerminator exception" do
      k1 = @kommand.new("some message")
      k2 = @kommand.new("some other message - this will never get processed")
      
      mock(k1).execute(anything){
        raise Sonar::Connector::ThreadTerminator.new
      }
      
      dont_allow(k2).execute
      
      mock.proxy(@consumer).cleanup
      
      @queue << k1
      @queue << k2
      
      @consumer.prepare(@queue)
      @consumer.watch
    end
    
  end
  
end
