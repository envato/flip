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

      strats.each_value { |s| return s.on?(d, options) if s.knows?(d, options) }
      return CustomLogicProxy.new(@strategies, d, options).on? if d.options[:fallback]
      default_for d
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

    class CustomLogicProxy
      def initialize(strategies, definition, options)
        @strategies = strategies
        @definition = definition
        @options = options
      end

      def on?
        instance_exec(&@definition.options[:fallback])
      end

      def method_missing(m, *args, &block)
        nice_name = m.to_s
        if nice_name =~ /\?$/
          nice_name = nice_name.gsub(/\?$/,'')
          if @strategies.has_key? nice_name
            strat = @strategies[nice_name]
            return strat.on?(@definition, @options)
          end
        end
        super(m, args, &block)
      end

    end

  end
end
