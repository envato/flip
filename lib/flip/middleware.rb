module Flip
  class Middleware
    class << self
      attr_reader :strategies
      def register(strategy)
        @strategies ||= []
        @strategies << strategy
      end
    end

    def initialize(app, feature_set_classes: [FeatureSet])
      @app = app
      @feature_set_classes = feature_set_classes
    end

    def call(env)
      req = Rack::Request.new(env)
      self.class.strategies.each{|s| s.before(req) }
      clear_flip_cache
      begin
        @app.call(env)
      ensure
        self.class.strategies.reverse.each{|s| s.after(req) }
      end
    end

    private

    def clear_flip_cache
      @feature_set_classes.each do |feature_set_class|
        feature_set_class.instance.data_store.clear_cache
      end
    end
  end
end
