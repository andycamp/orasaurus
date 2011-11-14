require 'spec_helper'

describe Orasaurus::Build do

  describe "#sort" do
    it "should default to alphabetic." do
      Orasaurus::Build.sort(["z","y","x"]).should eql ["x","y","z"]
    end
  end

end