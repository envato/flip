module HostSpecificValue
  def host_value(value)
    # "0 20@activeden.net 1@themeforest.net 50@audiojungle.net"
    # if host is activeden.net, we should get "20"
    # if host is themeforest.net, we should get "1"
    # if host is audiojungle, we should get "50"
    # if host is anything else, we should get "0"
    return nil unless value
    host = Flip::HostStrategy.host
    if host
      host = Regexp.escape(host)
      value_match = value.match(/([^\s]+)@#{host}/)
      return value_match[1] if value_match
    end
    nohost_value(value)
  end

  private
  def nohost_value(value)
    value.gsub(/[^\s]+@[^\s]+/,'').strip
  end
end
