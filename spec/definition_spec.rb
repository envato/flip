require "spec_helper"

describe Flip::Definition do

  subject { Flip::Definition.new :the_key, description: "The description", alias_name: :some_alias_name }

  [:key, :name, :to_s].each do |method|
    its(method) { should == :the_key }
  end

  its(:alias_name) { should == :some_alias_name }
  its(:description) { should == "The description" }
  its(:options) { should == { description: "The description", alias_name: :some_alias_name } }

  context "without description specified" do
    subject { Flip::Definition.new :the_key }
    its(:description) { should == "The key." }
  end

end
