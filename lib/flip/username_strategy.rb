# Database backed system-wide
module Flip
  class UsernameStrategy < AbstractStrategy

    KEY_SUFFIX = '_username'

    def initialize(data_store)
      @data_store = data_store
    end

    def description
      "Not persisted, applies to single user."
    end

    def knows?(definition, options = {})
      !feature(definition.key.to_s).nil?
    end

    #
    # expecting { :username => 'something' }
    #
    def on?(definition, options = {})
      if options[:username].nil?
        false
      else
        specified_by_username?(definition.key.to_s, options[:username])
      end
    end

    private

    def feature(key)
      @data_store.get(key + KEY_SUFFIX)
    end

    def specified_by_username?(key, username)
      usernames(key).include? username
    end

    def usernames(key)
      @data_store.get(key + KEY_SUFFIX).split(',')
    end
  end
end
