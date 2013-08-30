# Uses cookie to determine feature state.
require 'flip/middleware'
module Flip
  class CookieStrategy < AbstractStrategy
    Flip::Middleware.register self

    def description
      "Uses cookies to apply only to your session."
    end

    def knows?(definition, options = {})
      cookies.key? cookie_name(definition)
    end

    def on?(definition, options = {})
      cookies[cookie_name(definition)] === "true"
    end

    def switchable?
      true
    end

    def switch! key, on
      cookies[cookie_name(key)] = on ? "true" : "false"
    end

    def delete! key
      cookies.delete cookie_name(key)
    end

    def cookie_name(definition)
      definition = definition.key unless definition.is_a? Symbol
      "flip_#{definition}"
    end

    def self.before(req)
      @cookies = req.cookies
    end

    def self.after(req)
      @cookies = nil
    end

    private

    def cookies
      self.class.instance_variable_get(:@cookies) || {}
    end

  end
end
