# Database backed system-wide
module Flip
  class DeterministicPercentageStrategy < AbstractStrategy

    KEY_SUFFIX = '_percent'

    def initialize(data_store)
      @data_store = data_store
    end

    def description
      "Not persisted, applies to single user."
    end

    def knows?(definition, options = {})
      !feature(definition.key.to_s).nil?
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
