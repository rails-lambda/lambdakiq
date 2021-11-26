module Lambdakiq
  class Error < StandardError
  end

  class FifoDelayError < Error
    def initialize(error)
      super
      set_backtrace([])
    end
  end
end
