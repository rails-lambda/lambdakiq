require 'test_helper/events/base'
require 'test_helper/events/basic'

module TestHelper
  module EventHelpers

    private

    def event_basic(overrides = {})
      Events::Basic.create(overrides)
    end

  end
end
