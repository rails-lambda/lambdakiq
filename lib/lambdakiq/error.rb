module Lambdakiq
  class Error < StandardError
    attr_reader :original_exception, :job

    def initialize(error)
      @original_exception = error
      super(error.message)
      set_backtrace Rails.backtrace_cleaner.clean(error.backtrace)
    end
  end

  class JobError < Error ; end
end
