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
