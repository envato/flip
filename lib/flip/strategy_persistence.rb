module Flip
  module StrategyPersistence
    # active_record: id, definition_key, strategy, param_key, value
    # active_record: id, definition_key, strategy, enabled
    # redis hset "flipv2" "#{definition_key}-#{strategy}-#{param_key}" value
    def get(definition_key, param_key)
      data_store.get(definition_key, self.name, param_key)
    end

    def set(definition_key, param_key, value)
      data_store.set(definition_key, self.name, param_key, value)
    end

    private
    def data_store
      FeatureSet.instance.data_store
    end
  end
end
