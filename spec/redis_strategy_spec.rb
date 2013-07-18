require "spec_helper"

describe Flip::RedisStrategy do

  let(:definition) { double("definition").tap{ |d| d.stub(:key) { :one } } }
  let(:redis) { stub(:set => nil, :get => nil) }
  
  subject(:strategy) { Flip::RedisStrategy.new(redis) }

  its(:switchable?) { should be_true }
  its(:description) { should be_present }

  describe "#knows?" do
    it "does not know features that cannot be found" do
      redis.stub(:get) { nil }
      strategy.knows?(definition).should be_false
    end
    it "knows features that can be found" do
      redis.stub(:get) { 'feature_flag' }
      strategy.knows?(definition).should be_true
    end
  end

  describe "#on?" do
    it "is true for an enabled record from the database" do
      redis.stub(:get) { 'true' }
      strategy.on?(definition).should be_true
    end
    it "is false for a disabled record from the database" do
      redis.stub(:get) { 'false' }
      strategy.on?(definition).should be_false
    end
  end

  describe "#switch!" do
    it "can switch a feature on" do
      redis.should_receive(:set).with("flip_one", "true")
      strategy.switch! :one, true
    end
    it "can switch a feature off" do
      redis.should_receive(:set).with("flip_one", "false")
      strategy.switch! :one, false
    end
  end

  describe "#delete!" do
    it "can delete a feature record" do
      redis.should_receive(:del)
      strategy.delete! :one
    end
  end

end
