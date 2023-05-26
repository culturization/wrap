module TFB
  module IDObject
    attr_reader :id, :data

    def initialize(bot, id, data = {})
      @bot = bot
      @id = id || data['id']
      @data = data
    end
  end
end