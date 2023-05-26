# frozen_string_literal: true

require 'logger'
require 'websocket-client-simple'
require 'json'
require 'net/http'
require 'sqlite3'
require './lib/gateway'
require './lib/api'
require './lib/errors'
require './lib/id_object'
require './lib/container'
require './lib/options'

Dir['./lib/id/*.rb', './lib/containers/*.rb'].each { |f| require f }

require './lib/bot'

module Wrap
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
  VERSION = '0.2'
end