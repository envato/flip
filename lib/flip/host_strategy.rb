module Flip
  class HostStrategy < AbstractStrategy
    include StrategyPersistence

    def description
      "Enable feature for a list of http request hosts"
    end

    def knows?(definition, options = {})
      !allowed_hosts(definition).empty?
    end

    def valid_options
      return ['allowed_hosts']
    end

    def on?(definition, options = {})
      allowed_hosts(definition).include?(host)
    end

    def self.host= host
      @host = host
    end

    private
    def host
      self.class.instance_variable_get(:@host)
    end

    def allowed_hosts(definition)
      names_string = get(definition, "allowed_hosts") || ""
      names_string.split(/[\s,]+/)
    end

    # Include in ApplicationController to push sesion into SessionStrategy.
    # Users before_filter and after_filter rather than around_filter to
    # avoid pointlessly adding to stack depth.
    module Loader
      extend ActiveSupport::Concern
      included do
        before_filter :flip_host_strategy_before
        after_filter :flip_host_strategy_after
      end
      def flip_host_strategy_before
        HostStrategy.host = request.host
      end
      def flip_host_strategy_after
        HostStrategy.host = nil
      end
    end
  end
end
