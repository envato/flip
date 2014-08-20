require "spec_helper"

describe Flip::DeclarationStrategy do

  def definition(default)
    Flip::Definition.new :feature, default: default
  end

  describe "#knows?" do
    it "does not know definition with no default specified" do
      subject.knows?(Flip::Definition.new :feature).should be_false
    end
    it "does not know definition with default of nil" do
      subject.knows?(definition(nil)).should be_false
    end
    it "knows definition with default set to true" do
      subject.knows?(definition(true)).should be_true
    end
    it "knows definition with default set to false" do
      subject.knows?(definition(false)).should be_true
    end
  end

  describe "#on? for Flip::Definition" do
    subject { Flip::DeclarationStrategy.new.on? definition(default), options }
    [
      { default: true, result: true },
      { default: false, result: false },
      { default: proc { true }, result: true, name: "proc returning true" },
      { default: proc { false }, result: false, name: "proc returning false" },
      { default: proc { |d, o| o[:on] }, options: { on: true }, result: true, name: "proc inspecting options" },
      { default: proc { |d, o| o[:on] }, options: { on: false }, result: false, name: "proc inspecting options" },
    ].each do |parameters|
      context "with default of #{parameters[:name] || parameters[:default]} and options #{parameters[:options].inspect}" do
        let(:default) { parameters[:default] }
        let(:options) { parameters[:options] }
        it { should == parameters[:result] }
      end
    end
  end

end
