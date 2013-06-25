# earthquake_spec.rb
require "spec_helper"

describe Earthquake do
  before(:each) do
    ResqueSpec.reset!
  end

  describe "validations" do
    it "is not valid if a eqid already exists" do
      create(:earthquake, :eqid => 1)
      build(:earthquake, :eqid => 1).should_not be_valid
    end
  end

  describe ".import" do
    it "imports all quakes from the csv" do
      Earthquake.all.count.should  eq(0)
      Earthquake.import(File.join(File.dirname(__FILE__), '..', 'support', 'stubs', 'earthquakes.txt'))
      Earthquake.all.count.should  eq(5)
    end

    it "does not import duplicate quakes" do
      Earthquake.import(File.join(File.dirname(__FILE__), '..', 'support', 'stubs', 'earthquakes.txt'))
      Earthquake.all.count.should  eq(5)
      Earthquake.import(File.join(File.dirname(__FILE__), '..', 'support', 'stubs', 'earthquakes.txt'))
      Earthquake.all.count.should  eq(5)
    end
  end

  describe ".filter" do
    before(:each) do
      # import the quakes into the DB
      Earthquake.import(File.join(File.dirname(__FILE__), '..', 'support', 'stubs', 'earthquakes.txt'))
    end

    context "no filters passed" do
      let(:result) { Earthquake.filter({}) }

      it "returns all of the earthquakes" do
        result.count.should  eq(Earthquake.all.count)
      end

      it "returns an array of earthquakes" do
        result.should eq(Earthquake.all)
      end
    end

    context "source filter passed" do
      let(:result) { Earthquake.filter({"source" => "nc"}) }

      it "returns all of the earthquakes" do
        result.count.should   eq(2)
      end
    end

    context "on filter passed" do
      let(:result) { Earthquake.filter({"on" => "1371827382" }) }

      it "returns the quakes on the same day" do
        result.count.should  eq(1)
      end
    end

    context "since filter passed" do
      let(:result) { Earthquake.filter({"since" => "1372000182" }) }

      it "returns the quakes on the same day" do
        result.count.should  eq(3)
      end
    end

    context "over filter passed" do
      let(:result) { Earthquake.filter({"over" => "1.5" }) }

      it "returns the quakes on the same day" do
        result.count.should  eq(2)
      end
    end

    context "near filter passed" do
      let(:result) { Earthquake.filter({"near" => "38.7447,-122.6942" }) }

      it "returns the quakes on the same day" do
        result.count.should  eq(2)
      end
    end

    context "multiple filters passed" do
      let(:result) { Earthquake.filter({"near" => "38.7447,-122.6942", "over" => "1.2" }) }

      it "returns the quakes on the same day" do
        result.count.should  eq(2)
      end
    end
  end
end
