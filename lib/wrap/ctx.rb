# frozen_string_literal: true

module Wrap
  class Context
    attr_reader :event, :bot
  
    def initialize(bot, event)
      @bot = bot
      @event = event
    end

    def helper(...) = @bot.helper(...)
  end
end