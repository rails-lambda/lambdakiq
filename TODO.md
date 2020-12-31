
# TODO

* Do I need a worker module?
* Do I support vanillia ActiveJob?

```ruby
class ExampleJob < ActiveJob::Base
  retry_on ErrorLoadingSite, wait: 5.minutes, queue: :low_priority
```

* Do a some form of Async queue if this works on Lambda?
  - Does Sidekiq do this?

```ruby
def _enqueue(job, send_message_opts = {})
  Concurrent::Promise
  .execute { super(job, send_message_opts) }
  .on_error do |e|
    Rails.logger.error "Failed to queue job #{job}.  Reason: #{e}"
    error_handler = Aws::Rails::SqsActiveJob.config.async_queue_error_handler
    error_handler.call(e, job, send_message_opts) if error_handler
  end
end
```

* Use job's `attr_accessor :executions` vs `ApproximateReceiveCount`
* Error handlers. Ensure we easily hook into Rollbar, etc.
* Is `delete_message` message needed? Is 200 from consumer implied delete?
* Can I set Rails tempalte `VisibilityTimeout` to just +1 of function timeout or full 43200?

## Doc Points

* Same as Sidekiq
  - Interface
* Differences with Sidekiq
  - Max future/delay job is 15 minutes. Uses SQS `delay_seconds`.
  - Max retries is 12.
    * Sidekiq:    25 retries (20 days, 11 hours)
    * Lambdakiq:  12 retries (11 hours, 28 minutes)
* Client Optoins.
  - Uses `ENV['AWS_REGION']` for `region`. Likely never need to touch this.
  - Default Client Options. Show with config init or railtie?
* Max Message Size:
  - FIFO: 256 KB??

## Our Siqekiq Interfaces

```ruby
sidekiq_options queue: :bulk
sidekiq_options retry: 0
sidekiq_options backtrace: true, retry: 5
sidekiq_options retry: false
```

DO I MIRROR or MIGRATE

## Max Retries

* Max is twelve.
*

## Migrating from Sidekiq


#### Single Job

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :lambdakiq
end
```

#### Death Notifications

https://github.com/mperham/sidekiq/wiki/Error-Handling#death-notification


#### Optional

* Rename all `sidekiq_options` to `lambdakiq_options`

```ruby
ActiveJob::Base.logger = Logger.new(IO::NULL)
```
