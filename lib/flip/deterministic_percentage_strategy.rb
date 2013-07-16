module Flip
  class DeterministicPercentageStrategy < AbstractStrategy

    KEY_SUFFIX = '_deterministicpercent'

    def initialize(data_store = Flip::RedisStore.new)
      @data_store = data_store
    end

    def description
      "Not persisted, applies to single user."
    end

    def knows?(definition, options = {})
      !feature(definition.key.to_s).nil?
    end

    def get(definition)
      @data_store.get(definition.key.to_s + KEY_SUFFIX)
    end

    def set(definition, value)
      @data_store.set(definition.key.to_s + KEY_SUFFIX, value)
    end

    def valid_options
      return ['percentage']
    end

    #
    # expecting { :id => n }
    #
    def on?(definition, options = {})
      if options[:id].nil?
        false
      else
        within_percentage?(definition.key.to_s, options[:id])
      end
    end

    private

    def feature(key)
      @data_store.get(key + KEY_SUFFIX)
    end

    def within_percentage?(key, id)
      (id % 100) < percentage(key)
    end

    def percentage(key)
      @data_store.get(key + KEY_SUFFIX)
    end
  end
end
