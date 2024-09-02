module ActiveJob
  module QueueAdapters
    class LambdakiqAdapter

      def enqueue(job, options = {})
        job.lambdakiq_async? ? _enqueue_async(job, options) : _enqueue(job, options)
      end

      def enqueue_at(job, timestamp)
        enqueue job, delay_seconds: delay_seconds(timestamp)
      end

      def enqueue_after_transaction_commit?
        true
      end

      private

      def delay_seconds(timestamp)
        ds = (timestamp - Time.current.to_i).to_i
        [ds, 900].min
      end

      def _enqueue(job, options = {})
        queue = Lambdakiq.client.queues[job.queue_name]
        queue.send_message job, options
      end

      def _enqueue_async(job, options = {})
        Concurrent::Promise
          .execute { _enqueue(job, options) }
          .on_error { |e| async_enqueue_error(e) }
      end

      def async_enqueue_error(e)
        msg = "[Lambdakiq] Failed to queue job #{job}. Reason: #{e}"
        Rails.logger.error(msg)
      end

    end
  end
end
