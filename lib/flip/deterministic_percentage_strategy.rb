module Flip
  class DeterministicPercentageStrategy < AbstractStrategy
    include StrategyPersistence

    def description
      "Enable feature for a deterministic percent of users"
    end

    def knows?(definition, options = {})
      options[:id] && on?(definition, options)
    end

    def valid_options
      return ['percentage']
    end

    #
    # expecting { :id => n }
    #
    def on?(definition, options = {})
      within_percentage?(definition, options[:id])
    end

    private

    def within_percentage?(definition, id)
      id = "#{definition.to_s}-#{id}".hash
      (id % 100) < percentage(definition)
    end

    def percentage(definition)
      percentage = get(definition, "percentage") || 0
      percentage.to_i
    end
  end
end
