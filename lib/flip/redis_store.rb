module Flip
  class RedisStore < AbstractStore

    KEY_PREFIX = 'flip-'
    SAFE_TIMEOUT = 0.1

    def initialize(redis = Redis.current)
      @redis = redis
    end
    
    def get(definition, strategy, param_key)
      safely { @redis.hget([KEY_PREFIX, key(definition), strategy].join("-"), param_key) }
    end

    def set(definition, strategy, param_key, param_value)
      safely { @redis.hset([KEY_PREFIX, key(definition), strategy].join("-"), param_key, param_value) }
    end

    private

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
