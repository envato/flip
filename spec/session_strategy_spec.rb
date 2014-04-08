require "spec_helper"

describe Flip::SessionStrategy do

  let(:definition) { double("definition").tap{ |d| d.stub(:key) { :one } } }
  let(:session) { double }
  
  subject(:strategy) { Flip::SessionStrategy.new }

  its(:switchable?) { should be_true }
  its(:description) { should be_present }

  before do
    Flip::SessionStrategy.before(double(:session => session))
  end

  describe "#knows?" do
    it "does not know features that cannot be found" do
      session.stub(:key?) { false }
      strategy.knows?(definition).should be_false
    end
    it "knows features that can be found" do
      session.stub(:key?) { true }
      strategy.knows?(definition).should be_true
    end
  end

  describe "#on?" do
    it "is true for an enabled record from the session" do
      session.stub(:[]) { "true" }
      strategy.on?(definition).should be_true
    end
    it "is false for a disabled record from the session" do
      session.stub(:[]) { 'false' }
      strategy.on?(definition).should be_false
    end
  end

  describe "#switch!" do
    it "can switch a feature on" do
      session.should_receive(:[]=).with("flip_one", "true")
      strategy.switch! :one, true
    end
    it "can switch a feature off" do
      session.should_receive(:[]=).with("flip_one", "false")
      strategy.switch! :one, false
    end
  end

  describe "#delete!" do
    it "can delete a feature record" do
      session.should_receive(:delete)
      strategy.delete! :one
    end
  end

end
