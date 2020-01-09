module Flip
  class AbstractStore
    def get(definition_key, strategy, param_key)
      raise NotImplementedError
    end

    def set(definition_key, strategy, param_key, param_value)
      raise NotImplementedError
    end

    def clear_cache
    end
  end
end
