module Flip
  class RedisStore < AbstractStore
    REDIS_HASH_KEY = 'flipv2'
    attr :logger

    def initialize(redis = Redis.current)
      @redis = redis
      @cache = {}
      @logger = Rails.logger if defined?(Rails)
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
        @redis.hset(REDIS_HASH_KEY, hash_key(definition, strategy, param_key), param_value)
      end
      get_cached
    end

    def cleanup_unused_keys(feature_set = Flip::FeatureSet.instance)
      existing_keys = feature_set.definitions.map(&:key)
      existing_strategies = feature_set.strategies.map(&:name)
      possible_combinations = existing_keys.product(existing_strategies)
      possible_prefixes = possible_combinations.map { |key, strat| "#{key}-#{strat}" }
      get_cached if @cache.empty?
      @cache.keys.each do |key|
        outdated = possible_prefixes.none? { |prefix| key.starts_with?(prefix) }
        safely { @redis.hdel(REDIS_HASH_KEY, key) } if outdated
      end
    end

    private

    def get_cached
      @cache = safely { @redis.hgetall(REDIS_HASH_KEY) } || {}
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
