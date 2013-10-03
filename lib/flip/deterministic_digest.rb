require 'digest/md5'

module Flip
  module DeterministicDigest
    extend self
    # we use our own digest implementation.
    # the one in ruby is only consistent within the same
    # ruby process - not across restarts/servers
    def digest(string)
      Digest::MD5.hexdigest(string).to_i(16)
    end
  end
end
