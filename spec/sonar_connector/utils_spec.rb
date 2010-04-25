require 'spec_helper'

describe Sonar::Connector::Utils do
  describe "du" do
    before do
      @test_dir = File.join(base_dir, 'test_du_dir')
      FileUtils.mkdir_p @test_dir
    end
    
    after do
      FileUtils.rm_rf @test_dir
    end
    
    it "should return error if it's not a directory" do
      lambda{
        Sonar::Connector::Utils.du('some bad dir')
      }.should raise_error(/not a directory/)
    end
    
    it "should return zero for an empty dir" do
      Dir[ File.join(@test_dir, '*') ].should == []
      Sonar::Connector::Utils.du(@test_dir).should == 0
    end
    
    it "should sum up filesizes" do
      sizes = [0, 1, 20, 3000, 40001]
      
      # create files of different sizes in the test dir
      sizes.each_with_index do |s,i|
        name = File.join(@test_dir, "#{i}.txt")
        File.open(name, 'w'){|f| f << (0...s).map{65.+(rand(25)).chr}.join }
      end
      
      Sonar::Connector::Utils.du(@test_dir).should == sizes.sum
    end
    
    it "should glob subdirs" do
      depth = 5
      sizes = [30, 40, 400, 500]
      sizes.each_with_index do |s, i| 
        dir = File.join @test_dir, *(0...depth).map{i.to_s}
        FileUtils.mkdir_p dir
        name = File.join dir, 'file.txt'
        File.open(name, 'w'){|f| f << (0...s).map{65.+(rand(25)).chr}.join }
      end
      Sonar::Connector::Utils.du(@test_dir).should == sizes.sum
    end
  end
  
  describe "timestamped_id" do
    before do 
      mock(@now = Object.new)
      mock(@now).to_i{1234}
      mock(@now).usec{1}
      mock(Time).now{@now}
    end
    
    it "should work without prefix" do
      Sonar::Connector::Utils.timestamped_id.should == "1234000001"
    end
    
    it "should work with prefix" do
      Sonar::Connector::Utils.timestamped_id("foo").should == "foo_1234000001"
    end
  end
end