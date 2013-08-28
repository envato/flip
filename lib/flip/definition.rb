module Flip
  class Definition

    attr_accessor :key
    attr_accessor :options
    attr_accessor :custom_logic

    def initialize(key, options = {}, &custom_logic)
      @key = key
      @options = options.reverse_merge \
        description: key.to_s.humanize + "."
      @custom_logic = custom_logic
    end

    alias :name :key
    alias :to_s :key

    def description
      options[:description]
    end

  end
end
