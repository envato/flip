# ActiveSupport dependencies.
%w{
  concern
  inflector
  core_ext/hash/reverse_merge
  core_ext/object/blank
}.each { |name| require "active_support/#{name}" }

# Flip files.
%w{
  controller_filters
  declarable
  definition
  facade
  feature_set
  forbidden
  
  abstract_strategy
  cookie_strategy
  database_strategy
  declaration_strategy
  redis_strategy
  session_strategy
  username_strategy
  deterministic_percentage_strategy

  abstract_store
  redis_store
}.each { |name| require "flip/#{name}" }

require "flip/engine" if defined?(Rails)

module Flip
  extend Facade
end
