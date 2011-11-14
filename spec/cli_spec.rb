require 'spec_helper'

describe Orasaurus::CLI do

  describe "#generate" do 
    
    before(:each) do
      cleanup
    end
    
    it "should be able to generate build scripts" do
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_false
      capture(:stdout){ Orasaurus::CLI.start(["generate","build_scripts", "--base_dir=#{File.dirname(__FILE__) + '/sampleApp'}"]) }  
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_true
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/teardown.sql').should be_false   
    end 
    
    it "should be able to generate teardown scripts" do
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/teardown.sql').should be_false
      capture(:stdout){ Orasaurus::CLI.start(["generate","teardown_scripts", "--base_dir=#{File.dirname(__FILE__) + '/sampleApp'}"]) }  
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_false
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/teardown.sql').should be_true
    end    
    
    it "should be able to generate all scripts" do
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_false
      capture(:stdout){ Orasaurus::CLI.start(["generate","all", "--base_dir=#{File.dirname(__FILE__) + '/sampleApp'}"]) }  
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_true
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/teardown.sql').should be_true   
    end
    
    it "should have default functionality" do
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_false
      capture(:stdout){ Orasaurus::CLI.start(["generate","all", "--base_dir=#{File.dirname(__FILE__) + '/sampleApp'}"]) }  
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_true
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/teardown.sql').should be_true   
    end
    
  end

  after(:all) do
    cleanup
  end
  
end