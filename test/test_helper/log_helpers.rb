module TestHelper
  module LogHelpers
    extend ActiveSupport::Concern

    included do
      let(:active_job_log)  { ActiveJob::Base.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).string }
    end

    private

    def reset_active_job_logger!
      ActiveJob::Base.logger = Logger.new(StringIO.new)
    end
  end
end
