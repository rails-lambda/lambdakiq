

# TODO

* Do I need a worker module?
  A: Yes.
* Do I support vanillia ActiveJob?
  A: No, these are not compatible.

```ruby
class AjRetryOnAndWait < ApplicationJob
  retry_on ArgumentError, wait: 5.minutes
```

* Do a some form of Async queue if this works on Lambda?
  - Does Sidekiq do this?

```ruby
lambdakiq_options async: true
```

* Error handlers. Ensure we easily hook into Rollbar, etc.
* Can I set Rails tempalte `VisibilityTimeout` to just +1 of function timeout or full 43200?
* Do this in our gem. `ActiveJob::Base.logger = Logger.new(IO::NULL)`

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
* Setting `maxReceiveCount` hard codes your retries to -1 of that value at the queue level.

Q: How do I handle job priorities?
A: Use different queues.

* How we allow FIFO queues to work with delay using message visibility.
* Your SQS queue must have a `RedrivePolicy` policy!
  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sqs-queues.html#aws-sqs-queue-redrive


https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification-template-anatomy-globals.html


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

## Migrating from Sidekiq

#### Change Worker

```ruby
class ApplicationJob < ActiveJob::Base
  include Sidekiq::Worker
  include Lambdakiq::Worker
end
```

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
config.after_initialize do
  config.active_job.logger = Rails.logger
  config.lambdakiq.metrics_logger = Rails.logger
end
```

Instrument enqueue_retry and retry_stopped
