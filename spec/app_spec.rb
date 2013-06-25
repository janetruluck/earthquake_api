# app.rb spec
require "spec_helper"

describe "Earthquake App" do
  before(:each) do
    ResqueSpec.reset!
  end

  it "responds to GET /" do
    get "/"
    last_response.should be_ok
  end

  it "responds to GET /earthquakes" do
    get "/earthquakes"
    last_response.should be_ok
  end

  context "already has a queue" do
    it "does not queue another import worker", :vcr do 
      Resque.enqueue(ImportJob)
      get "/import"
      Resque.size("import").should eq(1)
    end
  end
end
