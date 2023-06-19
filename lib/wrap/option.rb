# frozen_string_literal: true

module Wrap
  class CommandOption
    module OptionTypes
      SUB_COMMAND = 1
      SUB_COMMAND_GROUP = 2
      STRING = 3
      INTEGER = 4
      BOOLEAN = 5
      USER = 6
      CHANNEL = 7
      ROLE = 8
      MENTIONABLE = 9
      NUMBER = 10
      ATTACHMENT = 11
    end

    attr_reader :name, :type, :focused, :options, :value

    def initialize(option)
      @name = option['name']
      @type = option['type']
      @focused = option['focused']

      if [OptionTypes::SUB_COMMAND, OptionTypes::SUB_COMMAND_GROUP].include?(@type)
        @options = option['options'].map.to_h { [ _1['name'], self.class.new(_1) ] }
      else
        @value = option['value']
      end
    end

    def [](key)
      @options[key]
    end
  end
end
