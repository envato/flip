# Uses session to determine feature state.
module Flip
  class SessionStrategy < AbstractStrategy

    def description
      "Uses Rails session to apply only to your session."
    end

    def knows? definition
      session.key? session_key_name(definition)
    end

    def on? definition
      session[session_key_name(definition)] === "true"
    end

    def switchable?
      true
    end

    def switch! key, on
      session[session_key_name(key)] = on ? "true" : "false"
    end

    def delete! key
      session.delete session_key_name(key)
    end

    def self.session= session
      @session = session
    end

    def session_key_name(definition)
      definition = definition.key unless definition.is_a? Symbol
      "flip_#{definition}"
    end

    private

    def session
      self.class.instance_variable_get(:@session) || {}
    end

    # Include in ApplicationController to push sesion into SessionStrategy.
    # Users before_filter and after_filter rather than around_filter to
    # avoid pointlessly adding to stack depth.
    module Loader
      extend ActiveSupport::Concern
      included do
        before_filter :flip_session_strategy_before
        after_filter :flip_session_strategy_after
      end
      def flip_session_strategy_before
        SessionStrategy.session = session
      end
      def flip_session_strategy_after
        SessionStrategy.session = nil
      end
    end

  end
end
