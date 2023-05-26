# frozen_string_literal: true

module TFB
  class Application
    include IDObject

    def register_command(cmd)
      @bot.api_call('Post', "applications/#{@id}/commands", nil, cmd)
    end

    def bulk_overwrite(cmds)
      @bot.api_call('Put', "applications/#{@id}/commands", nil, cmds)
    end

    def commands
      @bot.api_call('Get', "applications/#{@id}/commands")
    end
  end
end