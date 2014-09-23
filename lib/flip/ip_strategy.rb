require 'flip/middleware'
module Flip
  class IpStrategy < AbstractStrategy
    include StrategyPersistence
    include HostSpecificValue
    Flip::Middleware.register self

    def description
      "Enable feature for a deterministic percentage of IPs"
    end

    def knows?(definition, options = {})
      on?(definition, options)
    end

    def valid_options
      return ['percentage']
    end

    def on?(definition, options = {})
      within_percentage?(definition, ip)
    end

    def self.before(req)
      @ip = req.ip
    end

    def self.after(req)
      @ip = nil
    end

    private
    def ip
      self.class.instance_variable_get(:@ip)
    end

    def within_percentage?(definition, ip)
      return false if ip.nil?
      
      ip_hash = Flip::DeterministicDigest.digest("#{definition.to_s}-#{ip}")
      (ip_hash % 100) < percentage(definition)
    end

    def percentage(definition)
      percentage = host_value(get(definition, "percentage")) || 0
      percentage.to_i
    end
  end
end
