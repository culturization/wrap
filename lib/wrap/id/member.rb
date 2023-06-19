# frozen_string_literal: true

module Wrap
  class Member
    attr_reader :guild_id, :user_id, :data

    def initialize(bot, guild, user_id, data = {})
      @bot = bot
      @guild = guild
      @user_id = user_id || data['user']['id']
      @data = data
    end

    def get
      @data = @bot.api_call('Get', "guilds/#{@guild.id}/members/#{user_id}", [:g, @guild.id])
    rescue Wrap::Errors::UnknownMember
      nil
    end

    def highest_role(roles = nil)
      roles ||= @guild.roles
      member_roles = @data['roles']

      roles.select { |role| member_roles.include?(role['id']) }
           .max_by { |role| role['position'] }
    end

    def ban
      @guild.ban(@user_id)
    end

    def higher_than?(other, roles = nil)
      roles ||= @guild.roles
      highest_role(roles)['position'] > other.highest_role(roles)['position']
    end
  end
end
