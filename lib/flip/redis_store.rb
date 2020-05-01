module Flip
  class RedisStore < AbstractStore
    REDIS_HASH_KEY = 'flipv2'
    attr :logger

    def initialize(redis: Redis.current, redis_hash_key: REDIS_HASH_KEY)
      @redis = redis
      @cache = {}
      @logger = Rails.logger if defined?(Rails)
      @redis_hash_key = redis_hash_key
    end

    def clear_cache
      @cache = {}
    end

    def get(definition, strategy, param_key)
      get_cached if @cache.empty?
      @cache[hash_key(definition, strategy, param_key)]
    end

    def set(definition, strategy, param_key, param_value)
      safely do
        @redis.hset(@redis_hash_key, hash_key(definition, strategy, param_key), param_value)
      end
      get_cached
    end

    def cleanup_disused_keys(feature_set = Flip::FeatureSet.instance)
      existing_keys = feature_set.definitions.map(&:key)
      existing_strategies = feature_set.strategies.map(&:name)
      possible_combinations = existing_keys.product(existing_strategies)
      possible_prefixes = possible_combinations.map { |key, strat| "#{key}-#{strat}" }
      get_cached if @cache.empty?
      @cache.keys.map { |key|
        outdated = possible_prefixes.none? { |prefix| key.start_with?(prefix) }
        if outdated
          safely { @redis.hdel(@redis_hash_key, key) }
          key
        end
      }.compact
    end

    private

    def get_cached
      @cache = safely { @redis.hgetall(@redis_hash_key) } || {}
    end

    def hash_key(definition, strategy, param_key)
      [key(definition), strategy, param_key].join('-')
    end

    def safely
      if defined?(Redis)
        begin
          yield
        rescue Redis::BaseError => e
         logger.warn("Flip had a problem with redis: #{e}")
          nil
        end
      end
    end

    def key(definition)
      definition = definition.key unless definition.is_a? Symbol
      definition.to_s
    end
  end
end
