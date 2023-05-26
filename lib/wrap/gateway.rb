# frozen_string_literal: true

require 'websocket-client-simple'

module WebSocket
  module Client
    module Simple
      class Client
        attr_reader :thread
      end
    end
  end
end

module Wrap
  class Gateway
    DEFAULT_GATEWAY_URL = 'wss://gateway.discord.gg/?v=9&encoding=json'

    module Opcode
      DISPATCH = 0
      HEARTBEAT = 1
      IDENTIFY = 2
      RESUME = 6
      RECONNECT = 7
      INVALID_SESSION = 9
      HELLO = 10
    end

    def initialize(bot)
      @bot = bot
      @gateway_url = @bot.api_call('Get', 'gateway')['url']
    end

    def run
      loop do
        connect
        break unless @reconnect

        @reconnect = nil
      end
    end

    def close(reason = nil)
      LOGGER.warn("Connection closed by client#{", reason: #{reason}" if reason}")
      @ws.close
    end

    def reconnect(reason)
      @reconnect = true
      close(reason)
    end

    def send(msg)
      @ws.send(msg.to_json)
    end

    private

    def connect
      @ws = WebSocket::Client::Simple.connect(@gateway_url)

      @ws.on(:message, &method(:handle_message))
      @ws.on(:open) { LOGGER.info('Connected') }
      @ws.on(:error) { |e| LOGGER.error(e.full_message) }

      @ws.on(:close) do |e|
        LOGGER.warn("Disconnected from server: #{e}")
        @heartbeat_thread&.kill
      end

      @ws.thread.join
    end

    def handle_message(msg)
      payload = JSON.parse(msg.data)

      case payload['op']
      when Opcode::DISPATCH
        if payload['t'] == 'READY'
          LOGGER.info('Ready')
          @session_id = payload['d']['session_id']
          @gateway_url = payload['d']['resume_gateway_url']
        end

        @seq = payload['s']
        @bot.dispatch(payload['t'], payload['d'])

      when Opcode::RECONNECT
        LOGGER.warn('Received Reconnect')
        @resume = true
        reconnect('reconnect')

      when Opcode::INVALID_SESSION
        @resume = payload['d']
        LOGGER.warn("Received Invalid Session, connection is#{' not' unless @resume} resumable")
        reconnect('invalid session')

      when Opcode::HELLO
        LOGGER.debug('Hello')
        setup_heartbeat(payload)

        if @resume
          send_resume
          @resume = nil
        else
          send_identify
        end
      end
    end

    def send_heartbeat
      send('op' => Opcode::HEARTBEAT, 'd' => @seq)
      LOGGER.debug('Sent Heartbeat')
    end

    def setup_heartbeat(payload)
      @heartbeat_thread = Thread.new do
        interval = payload['d']['heartbeat_interval'] / 1000.0

        loop do
          send_heartbeat
          sleep(interval)
        end
      end
    end

    def send_identify
      send(
        op: Opcode::IDENTIFY,
        d: {
          token: @bot.token,
          properties: { '$os' => 'linux' },
          intents: @bot.intents
        }
      )
      LOGGER.debug('Sent Identify')
    end

    def send_resume
      send(
        op: Opcode::RESUME,
        d: {
          token: @bot.token,
          session_id: @session_id,
          seq: @seq
        }
      )
      LOGGER.debug('Sent Resume')
    end
  end
end
