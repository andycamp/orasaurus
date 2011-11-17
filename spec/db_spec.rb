require 'spec_helper'
require'oci8'

describe Orasaurus::DB do

  before(:all) do
    @sampleDB = Orasaurus::DB::Connection.new("ben","franklin")
  end

  describe "#connect" do
    
    it "should be able to connect to the db." do
      Orasaurus::DB::Connection.new("ben","franklin").should_not be_nil
    end
    
    it "should refuse bad credentials" do
      expect{ Orasaurus::DB::Connection.new("ben","adams") }.to raise_error
    end
    
  end

  describe "#determine_object_type" do
  
    it "should return the appropriate object type." do
      @sampleDB.determine_object_type('ben','notes').should == 'TABLE'
      @sampleDB.determine_object_type('ben','junk').should be_nil
    end

  end
  
  describe "#get_dependencies" do
    
    it "should return the correct depency list for a table" do
      @sampleDB.get_dependencies('ben','notes').first[:object_name].should == 'NOTEBOOKS'
    end
    
  end

  after(:all) do
    @sampleDB.logoff
  end

end