module Flip
  class FeatureSet

    def self.instance
      @instance ||= self.new
    end

    def self.reset
      @instance = nil
    end

    # Sets the default for definitions which fall through the strategies.
    # Accepts boolean or a Proc to be called.
    attr_writer :default, :data_store
    attr_reader :data_store

    def initialize
      @definitions = Hash.new { |_, k| raise "No feature declared with key #{k.inspect}" }
      @strategies = Hash.new { |_, k| raise "No strategy named #{k}" }
      @default = false
      @data_store = nil
    end

    # Whether the given feature is switched on.
    def on?(key, options = {})
      definition = @definitions[key]

      strategies = if definition.options[:strategies]
        definition_strategies = definition.options[:strategies].map(&:to_s)
        @strategies.values_at(*definition_strategies)
      else
        @strategies.values
      end

      knowing_strategies = strategies.select do |strategy|
        strategy.knows?(definition, options)
      end

      if knowing_strategies.any?
        knowing_strategies.any? do |strategy|
          strategy.on?(definition, options)
        end
      else
        default_for(definition, options)
      end
    end

    # Whether the given feature is defined.
    def has?(key)
      @definitions.has_key?(key)
    end

    # Adds a feature definition to the set.
    def << definition
      @definitions[definition.key] = definition
    end

    # Adds a strategy for determing feature status.
    def add_strategy(strategy)
      strategy = strategy.new if strategy.is_a? Class
      @strategies[strategy.name] = strategy
    end

    def strategy(klass)
      @strategies[klass]
    end

    def default_for(definition, options)
      if definition.options.include? :default
        default = definition.options[:default]
      else
        default = @default
      end

      if default.is_a? Proc
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

    def definitions
      @definitions.values
    end

    def strategies
      @strategies.values
    end
  end
end
