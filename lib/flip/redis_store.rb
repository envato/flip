module Flip
  class RedisStore < AbstractStore

    KEY_PREFIX = 'flip-'
    SAFE_TIMEOUT = 0.1

    def initialize(redis = Redis.current)
      @redis = redis
    end
    
    def get(definition_key, strategy, param_key)
      safely { @redis.hget([KEY_PREFIX, definition_key, strategy].join("-"), param_key) }
    end

    def set(definition_key, strategy, param_key, param_value)
      safely { @redis.hset([KEY_PREFIX, definition_key, strategy].join("-"), param_key, param_value) }
    end

    private
    def safely
      begin
        Timeout.timeout(SAFE_TIMEOUT){
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
end
