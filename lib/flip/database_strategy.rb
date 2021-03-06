# Database backed system-wide
module Flip
  class DatabaseStrategy < AbstractStrategy

    def initialize(feature_set: nil, model_klass: Feature)
      super(feature_set: feature_set)
      @klass = model_klass
    end

    def description
      "Database backed, applies to all users."
    end

    def knows?(definition, options = {})
      !!feature(definition)
    end

    def on?(definition, options = {})
      feature(definition).enabled?
    end

    def switchable?
      true
    end

    def switch! key, enable
      @klass.find_or_initialize_by_key(key.to_s).update_attributes! enabled: enable
    end

    def delete! key
      @klass.find_by_key(key.to_s).try(:destroy)
    end

    private

    def feature(definition)
      @klass.find_by_key definition.key.to_s
    end

  end
end
