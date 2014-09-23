# Uses :default option passed to feature declaration.
# May be boolean or a Proc to be passed the definition.
module Flip
  class DeclarationStrategy < AbstractStrategy

    def description
      "The default status declared with the feature."
    end

    def knows?(definition, options = {})
      !definition.options[:default].nil?
    end

    def on?(definition, options = {})
      default = definition.options[:default]

      if default.is_a?(Proc)
        if default.arity == 2
          default.call(definition, options)
        elsif default.arity == 1
          default.call(definition)
        else
          default.call
        end
      else
        default
      end
    end

  end
end
