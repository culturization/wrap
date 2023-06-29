# frozen_string_literal: true

module Wrap
  class Context
    attr_reader :ctx, :bot
  
    def initialize(bot, ctx)
      @bot = bot
      @ctx = ctx
      @helpers = @bot.helpers.map.to_h { |name, meth| [ name, meth.bind(self) ] }
    end

    def method_missing(name, ...)
      @helpers.fetch(name).call(...)
    end
  end
end