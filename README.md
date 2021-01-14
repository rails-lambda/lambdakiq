
![Lambdakiq Logo](images/Lambdakiq.png)

# ActiveJobs on Lambda

(serverless sidekiq)


TODO ...

```ruby
# TODO ...
```

## Usage

Open `config/application.rb` and set Lambdakiq as your default ActiveJob queue adapter.

```ruby
module YourApp
  class Application < Rails::Application
    config.active_job.queue_adapter = :lambdakiq
  end
end
```


## Standard or FIFO?

...

## Observability: CloudWatch Embedded Metrics

Get ready to gain way more insights into your ActiveJobs using AWS' [CloudWatch](https://aws.amazon.com/cloudwatch/) service. Every AWS service, including SQS & Lambda, publishes detailed [CloudWatch Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html). This gem leverages [CloudWatch Embedded Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format.html) to add detailed ActiveJob metrics to that system. You can mix and match these data points to build your own [CloudWatch Dashboards](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html). If needed, any combination can be used to trigger [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html).

Metrics are published under the `Lambdakiq` namespace. This is configurable using `config.lambdakiq.metrics_namespace` but should not be needed since all metrics are published using these three dimensions which allow you to easily segment metrics/dashboards to a specific application.

* `AppName` - This is the name of your Rails application. Ex: `MyApp`
* `JobEvent` - Name of the ActiveSupport Notification. Ex: `*.active_job`.
* `JobName` - The class name of the ActiveSupport job. Ex: `NotificationJob`

For reference, here are the `JobEvent` names published by ActiveSupport. A few of these are instrumented by Lambdakiq since we use custom retry logic like Sidekiq. These event/metrics are found in the Rails application CloudWatch logs.

* `enqueue.active_job`
* `enqueue_at.active_job`

While these event/metrics can be found in the jobs function's log.

* `perform_start.active_job`
* `perform.active_job`
* `enqueue_retry.active_job`
* `retry_stopped.active_job`

These are the properties published with each metric.

* `JobId` - ActiveJob Unique ID. Ex: `9f3b6977-6afc-4769-aed6-bab1ad9a0df5`
* `QueueName` - SQS Queue Name. Ex: `myapp-JobsQueue-14F18LG6XFUW5.fifo`
* `MessageId` - SQS Message ID. Ex: `5653246d-dc5e-4c95-9583-b6b83ec78602`
* `ExceptionName` - Class name of error raised. Present in perform and retry events.
* `EnqueuedAt` - When ActiveJob enqueued the message. Ex: `2021-01-14T01:43:38Z`
* `Executions` - The number of current executions. Counts from `1` and up.
* `JobArg#{n}` - Enumerated serialized arguments.

And finally, here are the metrics which each dimension can chart.

* `Duration` - Of the job event in milliseconds.
* `Count` - Of the event.
* `ExceptionCount` - Of the event. Useful with `ExceptionName`.

### CloudWatch Dashboard Examples

...

### CloudWatch Insights Query Examples


```
fields @timestamp, Executions, @message
| filter ispresent(JobEvent) and JobEvent = 'perform.active_job'
| filter JobName = 'NotificationJob'
| sort @timestamp asc
| limit 20
```



## Contributing

After checking out the repo, run:

```shell
$ ./bin/bootstrap
$ ./bin/setup
$ ./bin/test
```

Bug reports and pull requests are welcome on GitHub at https://github.com/customink/lambdakiq. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Lambdakiq project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/customink/lambdakiq/blob/master/CODE_OF_CONDUCT.md).
