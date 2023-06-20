# frozen_string_literal: true

module Wrap
  class Interaction
    include IDObject

    module InteractionTypes
      PING = 1
      APPLICATION_COMMAND = 2
      MESSAGE_COMPONENT = 3
      APPLICATION_COMMAND_AUTOCOMPLETE = 4
      MODAL_SUBMIT = 5
    end

    attr_reader :application, :type, :guild, :channel, :member, :user, :token, :version, :message,
                :app_permissions, :locale, :guild_locale,
                :command_id, :command_name, :command_type, :resolved, :opts, :command_path,
                :custom_id, :component_type, :values, :components

    def initialize(...)
      super(...)
      initialize_instance_vars
    end

    def initialize_instance_vars
      @id = @data['id']
      @application = Application.new(@bot, @data['application_id'])
      @type = @data['type']
      @guild = Guild.new(@bot, @data['guild_id'])
      @channel = Channel.new(@bot, @data['channel'])
      @member = @guild.member(nil, @data['member']) if @data['member']
      @user = @data['user'] # TODO: user object
      @token = @data['token']
      @version = @data['version']
      @message = @data['message'] # TODO: message object
      @app_permissions = @data['app_permissions']
      @locale = @data['locale']
      @guild_locale = @data['guild_locale']

      return if @type == InteractionTypes::PING

      inner_data = @data['data']

      case @type
      when InteractionTypes::APPLICATION_COMMAND, InteractionTypes::APPLICATION_COMMAND_AUTOCOMPLETE
        @command_id = inner_data['id']
        @command_name = inner_data['name']
        @command_type = inner_data['type']
        @resolved = inner_data['resolved']

        parse_options(inner_data['options'])
      when InteractionTypes::MESSAGE_COMPONENT
        @custom_id = inner_data['custom_id']
        @component_type = inner_data['component_type']
        @values = inner_data['values']
      when InteractionTypes::MODAL_SUBMIT
        @custom_id = inner_data['custom_id']
        @components = inner_data['components']
      end
    end

    def reply(msg)
      @bot.api_call('Post', "interactions/#{@id}/#{@token}/callback", nil, msg)
    end

    def parse_options(opts)
      opt = opts.first
      if opts.size == 1 && [1, 2].include?(opt['type'])
        opts = opt['options']
        @command_path = [@command_name, opt['name']]

        if opt['type'] == 2 # SUBCOMMAND GROUP
          opts = opt['options']
          @command_path << opts.first['name']
        end
      end

      @opts = opts.map { CommandOption.new(_1) }
    end
  end
end
