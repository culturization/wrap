# frozen_string_literal: true

module TFB
  class Channel
    include IDObject

    def send_message(msg)
      @bot.api_call('Post', "channels/#{@id}/messages", [:c, @id], msg)
    end

    def get
      @data = @bot.api_call('Get', "channels/#{@id}", [:c, @id])
    end
  end
end