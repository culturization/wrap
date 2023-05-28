# frozen_string_literal: true

module Wrap
  module Bot
    include API

    attr_reader :token, :ratelimits, :intents, :app

    def initialize(token)
      @token = token

      @command_handlers = {}
      @commands = []

      @ratelimits = {}

      @intents ||= 0

      @gateway = TFB::Gateway.new(self, @intents)
    end

    def include_containers(*containers)
      containers.each do |cont|
        @command_handlers.merge!(cont.instance_variable_get(:@command_handlers))
        @commands.concat(cont.instance_variable_get(:@commands))
      end
    end

    def run
      @gateway.run
    end

    def stop(reason = nil)
      @gateway&.close(reason)
    end

    def dispatch(event, data)
      case event
      when 'READY'
        # save application
        @app = app(nil, data)
      when 'MESSAGE_CREATE'
      when 'INTERACTION_CREATE'
        handler = @command_handlers[data['data']['name']]

        return if handler.nil?

        resp = handler.call(self, interaction(nil ,data))
        interaction(data['id']).reply(data['token'], wrap_msg(resp))
      end
    end

    # default wrap_msg
    def wrap_msg(resp)
      { type: 4, data: { content: resp } }
    end

    def channel(id, data = {})
      Channel.new(self, id, data)
    end

    def guild(id, data = {})
      Guild.new(self, id, data)
    end

    def app(id, data = {})
      Application.new(self, id, data)
    end

    def interaction(id, data = {})
      Interaction.new(self, id, data)
    end

    def overwrite_commands
      @app.bulk_overwrite(@commands)
    end
  end
end
