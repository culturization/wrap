# frozen_string_literal: true

module Wrap
  class Guild
    include IDObject

    def ban(user_id)
      @bot.api_call('Put', "guilds/#{@id}/bans/#{user_id}", [:g, @id], {})
    end

    def roles
      @bot.api_call('Get', "guilds/#{@id}/roles", [:g, @id])
    end

    def member(user_id, data = {})
      Member.new(@bot, self, user_id, data)
    end
  end
end