# frozen_string_literal: true

module Wrap
  class SlashCommand
    attr_reader :handlers

    def initialize(name, params = {}, &block)
      @name = name.to_s
      @params = params
      @options = []
      @handlers = {}

      instance_eval(&block) if block_given?
    end

    def group(name:, desc:, &block)
      group = SubcommandGroup.new([@name, name.to_s], desc, &block)
      @options << group.to_h
      @handlers.merge!(group.handlers)
    end

    def subcommand(name:, desc:, &block)
      subcmd = Subcommand.new([@name, name.to_s], desc, &block)
      @options << subcmd.to_h
      @handlers[subcmd.path] = subcmd.handler_
    end

    def handler(&block)
      @handlers[[@name]] = block
    end

    def option(params)
      @options << params
    end

    def to_h
      @params.merge(
        name: @name,
        options: @options
      )
    end
  end

  class SubcommandGroup
    attr_reader :handlers

    def initialize(path, desc, &block)
      @path = path
      @desc = desc
      @options = []
      @handlers = {}

      instance_eval(&block)
    end

    def subcommand(name:, desc:, &block)
      subcmd = Subcommand.new(@path + [name.to_s], desc, &block)
      @options << subcmd.to_h
      @handlers[subcmd.path] = subcmd.handler_
    end

    def to_h
      {
        name: path.last,
        type: 2,
        description: @desc,
        options: @options
      }
    end
  end

  class Subcommand
    attr_reader :path, :handler_

    def initialize(path, desc, &block)
      @path = path
      @desc = desc
      @options = []

      instance_eval(&block) if block_given?
    end

    def handler(&block)
      @handler_ = block
    end

    def option(params)
      @options << params
    end

    def to_h
      {
        name: path.last,
        type: 1,
        description: @desc,
        options: @options
      }
    end
  end
end
