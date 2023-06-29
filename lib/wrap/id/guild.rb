# frozen_string_literal: true

module Wrap
  class Guild
    include IDObject

    def ban(user_id, reason: nil)
      headers = reason.nil? ? nil : { 'X-Audit-Log-Reason' => URI.encode_uri_component(reason) }
      @bot.api_call('Put', "guilds/#{@id}/bans/#{user_id}", [:g, @id], {}, headers)
    end

    def roles
      @bot.api_call('Get', "guilds/#{@id}/roles", [:g, @id])
    end

    def member(user_id, data = {})
      Wrap::Member.new(@bot, self, user_id, data)
    end
  end
end
