require 'flip/middleware'
module Flip
  class HostStrategy < AbstractStrategy
    include StrategyPersistence
    Flip::Middleware.register self

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

    def self.before(req)
      @host = req.host
    end

    def self.after(req)
      @host = nil
    end

    def self.host
      @host
    end

    private
    def host
      self.class.host
    end

    def allowed_hosts(definition)
      names_string = get(definition, "allowed_hosts") || ""
      names_string.split(/[\s,]+/)
    end
  end
end
