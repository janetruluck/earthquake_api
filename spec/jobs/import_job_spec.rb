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

  describe "wait time arguement passed" do
    it "Queues a jobe with the passed wait time" do 
      Resque.enqueue(ImportJob, 5)
      ImportJob.should have_queued(5)
    end
  end

  describe "no wait time argument passed" do
    it "Queues a job with a 1 minute wait" do
      Resque.enqueue(ImportJob)
      ImportJob.should have_queued
    end
  end
end
