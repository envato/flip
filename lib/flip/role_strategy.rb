module Flip
  class RoleStrategy < AbstractValueInListStrategy

    def description
      "Enable feature for a list of roles"
    end

    def value_param_name
      :roles
    end

  end
end
