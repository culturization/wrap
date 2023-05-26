# frozen_string_literal: true

module TFB
  class Bot
    include API

    attr_reader :token, :db, :ratelimits

    def initialize(token, config)
      @token = token
      @config = config

      @db = SQLite3::Database.new(config['db'])

      @command_handlers = {}
      @commands = []

      include(Container::Misc, Container::Moderation)

      @ratelimits = {}
      @gateway = TFB::Gateway.new(self, config['intents'])
    end

    def include(*containers)
      containers.each do |cont|
        @command_handlers.merge!(cont.instance_variable_get(:@command_handlers))
        @commands.concat(cont.instance_variable_get(:@commands))
      end
    end

    def run
      app(@config['app_id']).bulk_overwrite(@commands)

      @gateway.run
    end

    def stop(reason = nil)
      @gateway&.close(reason)
    end

    def dispatch(event, data)
      case event
      when 'MESSAGE_CREATE'
      when 'INTERACTION_CREATE'
        handler = @command_handlers[data['data']['name']]

        return if handler.nil?

        resp = handler.call(self, data)
        interaction(data['id']).reply(data['token'], wrap_msg(resp))
      end
    end

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
      app(@config['app_id']).bulk_overwrite(@commands)
    end
  end
end