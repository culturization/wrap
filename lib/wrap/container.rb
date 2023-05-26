# frozen_string_literal: true

module TFB
  module Container
    def register_command(json)
      @commands ||= []
      @commands << json
    end

    def handle_command(cmd, &block)
      @command_handlers ||= {}
      @command_handlers[cmd] = block
    end
  end
end