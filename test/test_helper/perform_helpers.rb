module TestHelper
  module PerformBuffer
    def clear
      values.clear
    end

    def add(value)
      values << value
    end

    def values
      @values ||= []
    end

    def last_value
      values.last
    end

    extend self
  end
  module PerformHelpers
    private

    def perform_buffer_clear!
      PerformBuffer.clear
    end

    def perform_buffer_last_value
      PerformBuffer.last_value
    end
  end
end
