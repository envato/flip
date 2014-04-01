module Flip
  require 'timeout'
  class RedisStore < AbstractStore
    class CacheReadFailure < StandardError; end
    REDIS_HASH_KEY = 'flipv2'
    SAFE_TIMEOUT = 0.1

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
      safely do
        if redis_hash = @redis.hgetall(REDIS_HASH_KEY)
          @cache = redis_hash
        end
      end
      @cache ||= {}
    end

    def hash_key(definition, strategy, param_key)
      [key(definition), strategy, param_key].join('-')
    end

    def safely
      if defined?(Redis)
        begin
          Timeout.timeout(SAFE_TIMEOUT) {
            yield
          }
        rescue Redis::BaseError => e
         logger.warn("Flip had a problem with redis: #{e}")
          nil
        rescue Timeout::Error => e
          logger.warn("Flip redis operation took too long: #{e}")
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
