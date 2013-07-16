# Redis backed system-wide
module Flip
  class RedisStrategy < AbstractStrategy

    KEY_PREFIX = "flip_"

    def initialize(redis = Redis.current)
      @redis = redis
    end

    def description
      "Redis backed, applies to all users."
    end

    def knows? definition
      !feature(definition).nil?
    end

    def on? definition
      feature(definition) == true.to_s
    end

    def switchable?
      true
    end

    def switch! key, enable
      @redis.set(KEY_PREFIX + key.to_s, enable.to_s)
    end

    def delete! key
      @redis.del(KEY_PREFIX + key.to_s)
    end

    private

    def feature(definition)
      @redis.get(KEY_PREFIX + definition.key.to_s)
    end

  end
end
