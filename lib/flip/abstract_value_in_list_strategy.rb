module Flip
  class AbstractValueInListStrategy < AbstractStrategy
    include StrategyPersistence

    def description
      raise NotImplementedError
    end

    def value_param_name
      raise NotImplementedError
    end

    def knows?(definition, options = {})
      options[value_param_name] && on?(definition, options)
    end

    def valid_options
      return ["allowed_values"]
    end

    def on?(definition, options = {})
      if options[value_param_name]
        values = Array(options[value_param_name])
        matching_values = allowed_values(definition) & values
        !matching_values.empty?
      end
    end

    private

    def allowed_values(definition)
      values_string = get(definition, "allowed_values") || ""
      values_string.split(/[\s,]+/)
    end
  end
end
