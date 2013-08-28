module Flip
  module Declarable

    def self.extended(base)
      FeatureSet.reset
    end

    # Adds a new feature definition, creates predicate method.
    def feature(key, options = {}, &custom_logic)
      FeatureSet.instance << Flip::Definition.new(key, options, &custom_logic)
    end

    # Adds a strategy for determining feature status.
    def strategy(strategy)
      FeatureSet.instance.add_strategy strategy
    end

    # The default response, boolean or a Proc to be called.
    def default(default)
      FeatureSet.instance.default = default
    end

    def data_store(data_store)
      FeatureSet.instance.data_store = data_store
    end

  end
end
