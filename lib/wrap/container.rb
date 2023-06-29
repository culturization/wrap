# frozen_string_literal: true

module Wrap
  module Container
    def command(name, desc:, perms: nil, dm_perm: false, nsfw: nil, &block)
      params = { description: desc }

      params[:default_member_permissions] = perms unless perms.nil?
      params[:dm_permission] = dm_perm unless dm_perm.nil?
      params[:nsfw] = nsfw unless nsfw.nil?

      cmd = Wrap::SlashCommand.new(name, params, &block)

      @commands ||= []
      @commands << cmd.to_h

      @command_handlers ||= {}
      @command_handlers.merge!(cmd.handlers)
    end

    def on_event(name, &block)
      @event_handlers ||= []
      @event_handlers << [name, block]
      # TODO: also update intents
    end
  end
end
