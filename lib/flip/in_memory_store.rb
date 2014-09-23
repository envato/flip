module Flip
  class InMemoryStore < AbstractStore
    def initialize
      reset
    end

    def get(definition, strategy, param_key)
      @data[key(definition, strategy, param_key)]
    end

    def set(definition, strategy, param_key, param_value)
      @data[key(definition, strategy, param_key)] = param_value
    end

    def reset
      @data = {}
    end

    private

    def key(definition, *args)
      k = unless definition.is_a?(Symbol)
            definition.key
          else
            definition
          end
      [k, *args].join('-')
    end
  end
end
