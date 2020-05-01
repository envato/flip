require 'spec_helper'
require 'json'

describe Flip::RedisStore do

  let(:redis) { double }
  let(:logger) { double(:warn => nil) }

  subject(:store) { Flip::RedisStore.new(redis: redis) }

  before do
    stub_const("Redis", Class.new)
    stub_const("Redis::BaseError", RuntimeError)
    store.stub(:logger => logger)
    store.clear_cache
  end

  describe "#set" do
    it "can save and get a flip setting" do
      expect(redis).to receive(:hgetall).and_return({})
      expect(redis).to receive(:hset).with('flipv2', 'purchase_flow-ip-global', 20)
      store.set(:purchase_flow, "ip", "global", 20)
    end

    context "with a different redis hash key" do
      subject(:store) { Flip::RedisStore.new(redis: redis, redis_hash_key: 'outage') }

      it "uses the passed in key" do
        expect(redis).to receive(:hgetall).and_return({})
        expect(redis).to receive(:hset).with('outage', 'purchase_flow-ip-global', 20)
        store.set(:purchase_flow, "ip", "global", 20)
      end
    end
  end

  describe "#get" do
    it "returns the expected value from redis" do
      expect(redis).to receive(:hgetall).with('flipv2').and_return({'purchase_flow-ip-global' => 'true'})
      expect(store.get(:purchase_flow,'ip','global')).to eq('true')
    end

    context "with a different redis hash key" do
      subject(:store) { Flip::RedisStore.new(redis: redis, redis_hash_key: 'outage') }

      it "uses the passed in key" do
        expect(redis).to receive(:hgetall).with('outage').and_return({'purchase_flow-ip-global' => 'true'})
        expect(store.get(:purchase_flow,'ip','global')).to eq('true')
      end
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

    context "with a different redis hash key" do
      subject(:store) { Flip::RedisStore.new(redis: redis, redis_hash_key: 'outage') }

      it "persists after the cache is cleared" do
        expect(redis).to receive(:hgetall).and_return({})
        expect(redis).to receive(:hset).with('outage','purchase_flow-ip-global',20)

        store.set(:purchase_flow, "ip", "global", 20)
        store.clear_cache

        expect(redis).to receive(:hgetall).with('outage').and_return({'purchase_flow-ip-global' => 20})
        expect(store.get(:purchase_flow, "ip", "global")).to eq(20)
      end
    end
  end

  describe "#cleanup_disused_keys" do
    before do
      expect(redis).to receive(:hgetall).with('flipv2').and_return({
        'feature1-strategy1-value' => 'true',
        'feature2-strategy1-value' => 'true',
        'feature1-strategy2-value' => 'false',
        'notafeature-strategy1-value' => 'false',
        'feature1-notastrategy-value' => 'false'
      })
    end

    let(:strategies) do
      [
        double(Flip::AbstractStrategy, :name => 'strategy1'),
        double(Flip::AbstractStrategy, :name => 'strategy2')
      ]
    end

    let(:features) do
      [
        double(Flip::Definition, :key => :feature1),
        double(Flip::Definition, :key => :feature2)
      ]
    end

    let(:feature_set) do
      double(Flip::FeatureSet, :strategies => strategies, :definitions => features)
    end

    it "deletes redis entries for removed features/strategies" do
      expect(redis).to receive(:hdel).with('flipv2', 'notafeature-strategy1-value')
      expect(redis).to receive(:hdel).with('flipv2', 'feature1-notastrategy-value')
      store.cleanup_disused_keys(feature_set)
    end
  end
end
