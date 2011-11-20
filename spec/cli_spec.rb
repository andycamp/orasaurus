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
  
    it "should be able to generate build scripts ordered by sql." do
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Packages/build.sql').should be_false
      capture(:stdout){ Orasaurus::CLI.start(["generate","build_scripts", "--base_dir=#{File.dirname(__FILE__) + '/sampleApp'}", "--sort_method=SQL", "--db_name=XE", "--db_username=ben", "--db_password=franklin"]) }  
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Tables/build.sql').should be_true
      File.exist?(File.dirname(__FILE__)+'/sampleApp/Notes/Tables/teardown.sql').should be_false 
      tblBuild = File.open(File.dirname(__FILE__)+'/sampleApp/Notes/Tables/build.sql', 'rb') { |f| f.read }      
      tblBuild.should match(/.*@notebooks\.sql.*@notes\.sql.*@note_tags\.sql.*/xm)
      tblBuild.should_not match(/.*@notes\.sql.*@notebooks\.sql.*@note_tags\.sql.*/xm)
    end
    
  end

  after(:all) do
    #cleanup
  end
  
end