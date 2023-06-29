# frozen_string_literal: true

require 'logger'
require 'websocket-client-simple'
require 'json'
require 'net/http'

require 'wrap/version'
require 'wrap/gateway'
require 'wrap/api'
require 'wrap/errors'
require 'wrap/id_object'
require 'wrap/container'
require 'wrap/option'
require 'wrap/command'

require 'wrap/id/application'
require 'wrap/id/channel'
require 'wrap/id/guild'
require 'wrap/id/interaction'
require 'wrap/id/member'
require 'wrap/id/message'

require 'wrap/bot'

module Wrap
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::DEBUG
end
