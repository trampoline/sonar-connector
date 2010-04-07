require 'spec_helper'

describe Sonar::Connector::Command do
  before do
    @command
  end
  
  describe "initialize" do
    it "should set proc" do
      proc = Proc.new {}
      c = Sonar::Connector::Command.new(proc)
      c.proc.should == proc
    end
  end
  
  describe "execute" do
    it "should be run in context" do
      
      # create a context instance with a #do_it method
      context = new_anon_class(Object, "MyContext"){
        def do_it(instance)
        end
      }.new
      
      # the proc to run calls #do_it on self, and passes in self, which should be one and the same
      proc = Proc.new { do_it(self) }
      
      # ensure that do_it gets called, and the self instance passed in is the context.
      mock(context).do_it(context)
      
      Sonar::Connector::Command.new(proc).execute(context)
    end
  end
end
