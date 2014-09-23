# Redis backed system-wide
module Flip
  class GlobalStrategy < AbstractStrategy
    include StrategyPersistence

    def description
      "Data store backed, applies to all users."
    end

    def knows?(definition, options = {})
      !feature(definition).blank?
    end

    def on?(definition, options = {})
      feature(definition) == true.to_s
    end

    def switchable?
      true
    end

    def switch! key, enable
      set(key, "enabled", enable.to_s)
    end

    def delete! key
      set(key, "enabled", nil)
    end

    private

    def feature(definition)
      get(definition, "enabled")
    end

  end
end
