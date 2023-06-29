# frozen_string_literal: true

module Wrap
  class Channel
    include IDObject

    def send_message(msg)
      @bot.api_call('Post', "channels/#{@id}/messages", [:c, @id], msg)
    end

    def get
      @data = @bot.api_call('Get', "channels/#{@id}", [:c, @id])
    end

    def message(id)
      @bot.message(id, channel_id: @id)
    end
  end
end
