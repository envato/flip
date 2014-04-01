require 'spec_helper'
require 'json'

describe Flip::RedisStore do

  let(:redis) { double }
  let(:logger) { double(:warn => nil) }

  subject(:store) { Flip::RedisStore.new(redis) }

  before do
    class Redis;end
    class Redis::BaseError < StandardError; end
    store.stub(:logger => logger)
    store.clear_cache
  end

  descibe "#set" do
    it "can save and get a flip setting" do
      expect(redis).to receive(:get).and_return(JSON.dump({:flip1 => 'yo'}))
      expect(redis).to receive(:set).with('flip-cache', JSON.dump({'flip1' => 'yo', 'purchase_flow-ip-global' => 20}))
      store.set(:purchase_flow, "ip", "global", 20)
      expect(store.get(:purchase_flow, "ip", "global")).to eq(20)
    end

    it "doesn't overwrite if the redis call returns nil" do
      expect(redis).to receive(:get).and_return(nil)
      expect { store.set(:purchase_flow, "ip", "global", 20) }.to raise_error(Flip::RedisStore::CacheReadFailure)
    end
  end

  describe "#get" do
    it "doesn't raise an error when redis takes too long" do
      expect(redis).to receive(:get) { sleep 10; nil}
      expect { store.get(:purchase_flow, "ip", "global") }.not_to raise_error
    end

    it "returns nil when redis takes too long" do
      expect(redis).to receive(:get) { sleep 10; nil}
      expect(store.get(:purchase_flow, "ip", "global")).to eq(nil)
    end

    it "logs an error when redis takes too long" do
      expect(redis).to receive(:get) { sleep 10; nil}
      expect(logger).to receive(:warn).with("Flip redis operation took too long: execution expired")
      expect(store.get(:purchase_flow, "ip", "global")).to eq(nil)
    end
  end

  describe "#clear_cache" do
    it "persists after the cache is cleared" do
      expect(redis).to receive(:get).and_return(JSON.dump({:flip1 => 'yo'}))
      expect(redis).to receive(:set).with('flip-cache', JSON.dump({'flip1' => 'yo', 'purchase_flow-ip-global' => 20}))

      store.set(:purchase_flow, "ip", "global", 20)
      store.clear_cache

      expect(redis).to receive(:get).and_return(JSON.dump({'flip1' => 'yo', 'purchase_flow-ip-global' => 20}))
      expect(store.get(:purchase_flow, "ip", "global")).to eq(20)
    end
  end
end