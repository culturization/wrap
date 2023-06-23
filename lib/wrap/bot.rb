# frozen_string_literal: true

module Wrap
  class Bot
    include Wrap::API
    include Wrap::Container

    attr_reader :token, :ratelimits, :app

    attr_accessor :intents

    def initialize(token, &block)
      @token = token

      @command_handlers = {}
      @commands = []
      @event_handlers = []
      @error_handlers = {}
      @ratelimits = {}

      @intents = 0
      @gateway = Wrap::Gateway.new(self)

      block.call(self) if block_given?
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

    def response_wrapper(&block)
      @response_wrapper = block
    end

    def on_error(err_class, msg = nil, &block)
      block = Proc.new { msg } unless msg.nil?

      @error_handlers[err_class] = block
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
        handle_interaction(data)
      end

      # create classes for various events later
      @event_handlers.select { _1[0] == event }.each { |handler| handler.call(bot, data) }
    end

    def handle_interaction(data)
      act = interaction(nil, data)

      return if act.type != 2 || act.command_type != 1

      handler = @command_handlers[act.command_path]

      return if handler.nil?

      resp = begin
        handler.call(act)
      rescue => e
        err_handler = @error_handlers[e.class]

        return LOGGER.error(e.full_message) if err_handler.nil?
        
        err_handler.call(e)
      end

      act.reply @response_wrapper.nil? ? resp : @response_wrapper.call(resp)
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
