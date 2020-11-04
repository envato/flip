require "spec_helper"
require 'rack'

describe Flip::Middleware do
  let(:app_result) { double('result') }
  let(:app) { double(call: app_result) }
  let(:feature_set_class) { double }
  let(:feature_set_classes) { [feature_set_class] }
  let(:env) { { 'PATH_INFO' => '/' } }
  subject(:middleware) { Flip::Middleware.new(app, feature_set_classes: feature_set_classes) }

  before do
    feature_set_class.stub_chain(:instance, :data_store, :clear_cache)
  end

  it "clears the cache for each feature set class on each request" do
    data_store = double
    expect(data_store).to receive(:clear_cache)
    instance = double
    expect(instance).to receive(:data_store).and_return(data_store)
    expect(feature_set_class).to receive(:instance).and_return(instance)
    middleware.call(env)
  end
end
