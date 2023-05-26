# frozen_string_literal: true

module TFB
  module Errors
    class DiscordError < StandardError
      attr_reader :message

      class << self
        attr_reader :code
      end

      def initialize(message)
        @message = message
      end
    end

    class OtherError < StandardError
      attr_reader :message, :code

      def initialize(message, code)
        @message = message
        @code = code
      end
    end

    module_function

    def create_err(code)
      class_ = Class.new(DiscordError)
      class_.class_eval { @code = code }
      @classes ||= {}
      @classes[code] = class_
    end

    def find_err(message, code)
      return @classes[code].new(message) if @classes && @classes.has_key?(code)
     
      OtherError.new(message, code)
    end

    UnknownError = create_err(0)

    UnknownMember = create_err(10007)

    MissingPermissions = create_err(50013)
  end
end