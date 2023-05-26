# frozen_string_literal: true

module TFB
  class Interaction
    include IDObject
  
    def reply(token, msg)
      @bot.api_call('Post', "interactions/#{@id}/#{token}/callback", nil, msg)
    end
  end
end