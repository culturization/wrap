# frozen_string_literal: true

module Wrap
  module Bot
    include API

    attr_reader :token, :ratelimits, :intents, :app

    def initialize(token)
      @token = token

      @command_handlers = {}
      @commands = []

      @event_handlers = {}

      @ratelimits = {}

      @intents ||= 0
      @gateway = Wrap::Gateway.new(self)
    end

    def include_containers(*containers)
      containers.each do |cont|
        event_handlers, command_handlers, commands = %i[
          @event_handlers @command_handlers @commands
        ].map { |var| cont.instance_variable_get(var) }

        @event_handlers.concat(event_handlers) unless event_handlers.nil?
        @command_handlers.merge!(command_handlers) unless command_handlers.nil?
        @commands.concat(commands) unless commands.nil?
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
        act = interaction(nil, data)

        return if act.type != 2 || act.command_type != 1

        handler = @command_handlers[act.command_path]

        return if handler.nil?

        resp = handler.call(self, act)
        act.reply(wrap_msg(resp))
      end

      # create classes for various events later
      @event_handlers.select { _1[0] == event }.each { |handler| handler.call(bot, data) }
    end

    # default wrap_msg
    def wrap_msg(resp)
      { type: 4, data: { content: resp } }
    end

    def channel(id, data = {})
      Wrap::Channel.new(self, id, data)
    end

    def guild(id, data = {})
      Wrap::Guild.new(self, id, data)
    end

    def app(id, data = {})
      Wrap::Application.new(self, id, data)
    end

    def interaction(id, data = {})
      Wrap::Interaction.new(self, id, data)
    end

    def overwrite_commands
      @app.bulk_overwrite(@commands)
    end
  end
end
