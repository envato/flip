module Flip
  class RedisStore < AbstractStore
    class FlakeyFlipFailure < StandardError; end
    KEY_PREFIX = 'flip'
    SAFE_TIMEOUT = 0.1

    def initialize(redis = Redis.current)
      @redis = redis
      @cache = {}
    end

    def clear_cache
      @cache = {}
    end

    def get(definition, strategy, param_key)
      get_cached if @cache == {}
      @cache[hash_key(definition, strategy, param_key)]
    end

    def set(definition, strategy, param_key, param_value)
      get_cached
      raise FlakeyFlipFailure.new("Got an empty cache, not overwriting") if @cache == {}
      @cache[hash_key(definition, strategy, param_key)] = param_value
      set_cached
    end

    def get_cached
      safely do
        if redis_hash = @redis.get("#{KEY_PREFIX}-cache")
          @cache = JSON.parse(redis_hash)
        else
          @cache = {}
        end
        @cache ||= {}
      end
    end

    def set_cached
      safely do
        remove_nil_from_cache
        @redis.set("#{KEY_PREFIX}-cache", JSON.dump(@cache))
      end
    end

    private

    def remove_nil_from_cache
      @cache.delete_if{|k,v| v.nil?}
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
          Rails.logger.warn("Flip had a problem with redis: #{e}")
          nil
        rescue Timeout::Error => e
          Rails.logger.warn("Flip redis operation took too long: #{e}")
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
