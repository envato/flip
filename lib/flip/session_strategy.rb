# Uses session to determine feature state.
require 'flip/middleware'
module Flip
  class SessionStrategy < AbstractStrategy
    Flip::Middleware.register self

    def description
      "Uses Rails session to apply only to your session."
    end

    def knows?(definition, options = {})
      session.key? session_key_name(definition)
    end

    def on?(definition, options = {})
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

    def session_key_name(definition)
      definition = definition.key unless definition.is_a? Symbol
      "flip_#{definition}"
    end
 
    def self.before(req)
      @session = req.session
    end

    def self.after(req)
      @session = nil
    end

    private

    def session
      self.class.instance_variable_get(:@session) || {}
    end
  end
end
