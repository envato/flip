module Flip
  class Middleware
    class << self
      attr_reader :strategies
      def register(strategy)
        @strategies ||= []
        @strategies << strategy
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      self.class.strategies.each{|s| s.before(req) }
      begin
        @app.call(env)
      ensure
        self.class.strategies.reverse.each{|s| s.after(req) }
      end
    end
  end
end
