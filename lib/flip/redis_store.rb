module Flip
  class RedisStore < AbstractStore

    KEY_PREFIX = 'flip_'

    def initialize(redis = Redis.current)
      @redis = redis
    end
    
    def get(key)
      @redis.get(KEY_PREFIX + key)
    end

    def set(key, value)
      @redis.set(KEY_PREFIX + key, value)
    end
  end
end