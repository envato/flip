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
      d = @definitions[key]
      strats = if d.options[:strategies]
        required_strats = d.options[:strategies].map(&:to_s)
        @strategies.select{|k,v| required_strats.include?(k)}
      else
        @strategies
      end

      on = strats.each_value.any? { |s| s.knows?(d,options) && s.on?(d, options) }
      on ||= default_for d
      on
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

    def default_for(definition)
      @default.is_a?(Proc) ? @default.call(definition) : @default
    end

    def definitions
      @definitions.values
    end

    def strategies
      @strategies.values
    end
  end
end
