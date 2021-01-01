module ActiveJob
  module QueueAdapters
    class LambdakiqAdapter

      def enqueue(job, options = {})
        queue = Lambdakiq.client.queues[job.queue_name]
        queue.send_message job, options
      end

      def enqueue_at(job, timestamp)
        enqueue job, delay_seconds: delay_seconds(timestamp)
      end

      private

      def delay_seconds(timestamp)
        ds = (timestamp - Time.current.to_i).to_i
        [ds, 900].min
      end

    end
  end
end
