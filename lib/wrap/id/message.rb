# frozen_string_literal: true

module Wrap
  class Message
    include IDObject

    attr_reader :channel, :author, :content, :timestamp, :edited_timestamp,
                :tts, :mention_everyone, :mentions, :mention_roles, :mention_channels, :attachments,
                :embeds, :reactions, :nonce, :pinned, :webhook_id, :type, :activity, :application,
                :message_reference, :flags, :referenced_message, :interaction, :thread, :components,
                :sticker_items, :position, :role_subscription_data

    def init_vars
      @id ||= @data['id']
      @channel = @bot.channel(@data['channel_id'])
      @author = @data['author']
      @content = @data['content']
      @timestamp = Time.iso8601(@data['timestamp'])
      @edited_timestamp = Time.iso8601(@data['edited_timestamp']) if @data['edited_timestamp']
      @tts = @data['tts']
      @mention_everyone = @data['mention_everyone']
      @mentions = @data['mentions']
      @mention_roles = @data['mention_roles']
      @mention_channels = @data['mention_channels']
      @attachments = @data['attachments']
      @embeds = @data['embeds']
      @reactions = @data['reactions']
      @nonce = @data['nonce']
      @pinned = @data['pinned']
      @webhook_id = @data['webhook_id']
      @type = @data['type']
      @activity = @data['activity']

      @application = if @data['application']
        @bot.app(nil, @data['application'])
      elsif @data['application_id']
        @bot.app(@data['application_id'])
      end

      @message_reference = @data['message_reference']
      @flags = @data['flags']
      @referenced_message = @data['referenced_message']
      @interaction = @bot.interaction(nil, @data['interaction']) if @data['interaction']
      @thread = @data['thread']
      @components = @data['components']
      @sticker_items = @data['sticker_items']
      @position = @data['position']
      @role_subscription_data = @data['role_subscription_data']
    end
  end
end