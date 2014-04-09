require 'spec_helper'
require 'json'

describe Flip::RedisStore do

  let(:redis) { double }
  let(:logger) { double(:warn => nil) }

  subject(:store) { Flip::RedisStore.new(redis) }

  before do
    stub_const("Redis", Class.new)
    stub_const("Redis::BaseError", StandardError.new)
    store.stub(:logger => logger)
    store.clear_cache
  end

  describe "#set" do
    it "can save and get a flip setting" do
      expect(redis).to receive(:hgetall).and_return({})
      expect(redis).to receive(:hset).with('flipv2', 'purchase_flow-ip-global', 20)
      store.set(:purchase_flow, "ip", "global", 20)
    end
  end

  describe "#get" do
    it "returns the expected value from redis" do
      expect(redis).to receive(:hgetall).with('flipv2').and_return({'purchase_flow-ip-global' => 'true'})
      expect(store.get(:purchase_flow,'ip','global')).to eq('true')
    end

    describe "errors" do
      before { expect(redis).to receive(:hgetall) { nil} }

      it "doesn't raise an error when redis takes too long" do
        expect { store.get(:purchase_flow, "ip", "global") }.not_to raise_error
      end

      it "returns nil when redis takes too long" do
        expect(store.get(:purchase_flow, "ip", "global")).to eq(nil)
      end
    end
  end

  describe "#clear_cache" do
    it "persists after the cache is cleared" do
      expect(redis).to receive(:hgetall).and_return({})
      expect(redis).to receive(:hset).with('flipv2','purchase_flow-ip-global',20)

      store.set(:purchase_flow, "ip", "global", 20)
      store.clear_cache

      expect(redis).to receive(:hgetall).with('flipv2').and_return({'purchase_flow-ip-global' => 20})
      expect(store.get(:purchase_flow, "ip", "global")).to eq(20)
    end
  end
end