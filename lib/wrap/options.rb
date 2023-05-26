# frozen_string_literal: true

module TFB
  class CommandOptions
    def initialize(ary)
      @ary = ary
    end

    def [](name)
      @ary.find { _1['name'] == name }&.[]('value')
    end
  end
end