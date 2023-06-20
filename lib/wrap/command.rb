# frozen_string_literal: true

module Wrap
  class SlashCommand
    attr_reader :options

    def initialize(bot, name, params = {}, &block)
      @bot = bot
      @name = name
      @options = []

      instance_eval(&block) if block_given?

      @bot.app.register_command(params.merge(name: name, options: @options))
    end

    def group(name:, desc:, &block)
      @options << SubcommandGroup.new([@name, name], desc, &block).to_h
    end

    def subcommand(name:, desc:, &block)
      @options << Subcommand.new([@name, name], desc, &block).to_h
    end

    def handler(&block)
      @bot.command_handlers[[@name]] << block
    end

    def option(params)
      @options << params
    end
  end

  class SubcommandGroup
    def initialize(path, desc, &block)
      @path = path
      @options = []

      instance_eval(&block)

      @hash = {
        name: path.last,
        type: 2,
        description: desc,
        options: @options
      }
    end

    def subcommand(name:, desc:, &block)
      @options << Subcommand.new(name, desc, &block).to_h
    end

    def to_h
      @hash
    end
  end

  class Subcommand
    def initialize(path, desc, &block)
      @path = path
      @options = []

      instance_eval(&block)

      @hash = {
        name: path.last,
        type: 1,
        description: desc,
        options: @options
      }
    end

    def handler(&block)
      @bot.command_handlers[@path] << block
    end

    def option(params)
      @options << params
    end

    def to_h
      @hash
    end
  end
end
