module Flip
  class UsernameStrategy < AbstractStrategy
    include StrategyPersistence

    def description
      "Enable feature for a list of usernames"
    end

    def knows?(definition, options = {})
      options[:username] && on?(definition, options)
    end

    def valid_options
      return ['allowed_usernames']
    end

    #
    # expecting { :username => 'something' }
    #
    def on?(definition, options = {})
      allowed_usernames(definition).include?(options[:username])
    end

    private

    def allowed_usernames(definition)
      names_string = get(definition, "allowed_usernames") || ""
      names_string.split(/[\s,]+/)
    end
  end
end
