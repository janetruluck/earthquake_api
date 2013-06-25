require 'spec_helper'

describe ImportJob do
  before(:each) do
    ResqueSpec.reset!
  end

  describe "#perform" do
    it "imports the csv and queue another import", :vcr do
      Earthquake.all.count.should eq(0)

      without_resque_spec do
        ImportJob.perform(0)
      end

      Earthquake.all.should_not be_empty
    end
  end
end
