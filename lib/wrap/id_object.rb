# frozen_string_literal: true

module Wrap
  module IDObject
    attr_reader :id, :data

    def initialize(bot, id, data = {})
      @bot = bot
      @id = id || data['id']
      @data = data

      init_vars if defined? init_vars
    end
  end
end
