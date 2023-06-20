# frozen_string_literal: true

module Wrap
  class SlashCommand
    attr_reader :options

    def initialize(bot, name, params = {}, &block)
      @bot = bot
      @name = name.to_s
      @options = []

      instance_eval(&block) if block_given?

      @bot.app.register_command(params.merge(name: name, options: @options))
    end

    def group(name:, desc:, &block)
      @options << SubcommandGroup.new([@name, name.to_s], desc, &block).to_h
    end

    def subcommand(name:, desc:, &block)
      @options << Subcommand.new([@name, name.to_s], desc, &block).to_h
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
    end

    def subcommand(name:, desc:, &block)
      @options << Subcommand.new(@path + [name.to_s], desc, &block).to_h
    end

    def to_h
      {
        name: path.last,
        type: 2,
        description: desc,
        options: @options
      }
    end
  end

  class Subcommand
    def initialize(path, desc, &block)
      @path = path
      @options = []

      instance_eval(&block) if block_given?
    end

    def handler(&block)
      @bot.command_handlers[@path] << block
    end

    def option(params)
      @options << params
    end

    def to_h
      {
        name: path.last,
        type: 1,
        description: desc,
        options: @options
      }
    end
  end
end
