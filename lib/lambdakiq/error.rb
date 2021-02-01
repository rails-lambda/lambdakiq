module Lambdakiq
  class Error < StandardError
  end

  class JobError < Error
    attr_reader :original_exception, :job

    def initialize(error)
      @original_exception = error
      super(error.message)
      set_backtrace Rails.backtrace_cleaner.clean(error.backtrace)
    end
  end

  class FifoDelayError < Error
    def initialize(error)
      super
      set_backtrace([])
    end
  end
end
