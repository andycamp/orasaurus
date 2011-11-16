require 'spec_helper'
require'oci8'

describe Orasaurus::DB do

  describe "#connect" do
    
    it "should be able to connect to the db." do
      Orasaurus::DB::Connection.new("ben","franklin").should_not be_nil
    end
    
    it "should refuse bad credentials" do
      expect{ Orasaurus::DB::Connection.new("ben","adams") }.to raise_error
    end
    
  end

end