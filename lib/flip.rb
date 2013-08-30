# ActiveSupport dependencies.
%w{
  concern
  inflector
  core_ext/hash/reverse_merge
  core_ext/object/blank
}.each { |name| require "active_support/#{name}" }

# Flip files.
%w{
  strategy_persistence
  abstract_store
  abstract_strategy
  abstract_value_in_list_strategy
  controller_filters
  cookie_strategy
  database_strategy
  declarable
  declaration_strategy
  definition
  deterministic_percentage_strategy
  facade
  feature_set
  forbidden
  global_strategy
  host_strategy
  middleware
  redis_store
  role_strategy
  session_strategy
  username_strategy
}.each { |name| require "flip/#{name}" }

module Flip
  extend Facade
end
