# frozen_string_literal: true

module Wrap
  module Container
    def register_command(hash)
      @commands ||= []
      @commands << hash
    end

    def handle_command(cmd, &block)
      @command_handlers ||= {}
      @command_handlers[cmd] = block
    end

    def handle_event(name, &block)
      @event_handlers ||= {}
      @event_handlers[name] = block
    end
  end
end
