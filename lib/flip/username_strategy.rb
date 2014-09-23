module Flip
  class UsernameStrategy < AbstractValueInListStrategy

    def description
      "Enable feature for a list of usernames"
    end

    def value_param_name
      :username
    end

  end
end
