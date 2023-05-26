# frozen_string_literal: true

require 'logger'
require 'websocket-client-simple'
require 'json'
require 'net/http'

require './lib/wrap/version'
require './lib/wrap/gateway'
require './lib/wrap/api'
require './lib/wrap/errors'
require './lib/wrap/id_object'
require './lib/wrap/container'
require './lib/wrap/option'

Dir['./wrap/id/*.rb'].sort.each { |f| require f }

require './lib/wrap/bot'

module Wrap
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::DEBUG
end
