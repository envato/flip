module Flip
  module Facade

    def on?(feature, options = {})
      FeatureSet.instance.on? feature, options
    end

    def reset
      FeatureSet.reset
    end

    def has_definition?(feature)
      FeatureSet.instance.has? feature
    end

    def method_missing(method, *parameters)
      super unless method =~ %r{^(.*)\?$}
      FeatureSet.instance.on? $1.to_sym
    end

  end
end
