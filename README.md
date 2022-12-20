![Lambdakiq: ActiveJob on SQS & Lambda](images/Lambdakiq.png)

![Test](https://github.com/customink/lambdakiq/workflows/Test/badge.svg)

# Lambdakiq

<a href="https://lamby.custominktech.com"><img src="https://raw.githubusercontent.com/customink/lamby/master/images/social2.png" alt="Lamby: Simple Rails & AWS Lambda Integration using Rack." align="right" width="450" style="margin-left:1rem;margin-bottom:1rem;" /></a>
A drop-in replacement for [Sidekiq](https://github.com/mperham/sidekiq) when running Rails in AWS Lambda using the [Lamby](https://lamby.custominktech.com) gem.

Lambdakiq allows you to leverage AWS' managed infrastructure to the fullest extent. Gone are the days of managing pods and long polling processes. Instead AWS delivers messages directly to your Rails' job functions and scales it up and down as needed. Observability is built in using AWS CloudWatch Metrics, Dashboards, and Alarms. Learn more about [Using AWS Lambda with Amazon SQS](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html) or get started now.

## Key Features

- Distinct web & jobs Lambda functions.
- AWS fully managed polling. Event-driven.
- Maximum 12 retries. Per job configurable.
- Mirror Sidekiq's retry [backoff](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry) timing.
- Last retry is at 11 hours 30 minutes.
- Supports ActiveJob's wait/delay. Up to 15 minutes.
- Dead messages are stored for up to 14 days.

## Project Setup

This gem assumes your Rails application is on AWS Lambda, ideally with our [Lamby](https://lamby.custominktech.com) gem. It could be using Lambda's traditional zip package type or the newer [container](https://dev.to/aws-heroes/lambda-containers-with-rails-a-perfect-match-4lgb) format. If Rails on Lambda is new to you, consider following our [quick start](https://lamby.custominktech.com/docs/quick_start) guide to get your first application up and running. From there, to use Lambdakiq, here are steps to setup your project

### Bundle & Config

Add the Lambdakiq gem to your `Gemfile`.

```ruby
gem 'lambdakiq'
```

Open `config/environments/production.rb` and set Lambdakiq as your ActiveJob queue adapter.

```ruby
config.active_job.queue_adapter = :lambdakiq
```

Open `app/jobs/application_job.rb` and add our worker module. The queue name will be set by an environment using CloudFormation further down.

```ruby
class ApplicationJob < ActiveJob::Base
  include Lambdakiq::Worker
  queue_as ENV['JOBS_QUEUE_NAME']
end
```

Using ActionMailer's built-in deliver job with ActiveJob? Make sure to include the Lambdakiq worker and set the queue name depending on your Rails version. You can do this in a newly created `config/initializers//action_mailer.rb` or another initializer of your choice.

```ruby
# Rails 5.x
ActionMailer::DeliveryJob.include Lambdakiq::Worker
ActionMailer::DeliveryJob.queue_as ENV['JOBS_QUEUE_NAME']
# Rails 6.x
ActionMailer::MailDeliveryJob.include Lambdakiq::Worker
ActionMailer::MailDeliveryJob.queue_as ENV['JOBS_QUEUE_NAME']
```

The same Docker image will be used for both your `web` and `jobs` functions (example setup in following sections). The [Lamby](https://lamby.custominktech.com) gem can automatically can detect if Lambdakiq is present when using the newer `Lamby.cmd` or older lower `Lamby.handler` method. That said, please take a look at the `JobsLambda` in the following section and how `ImageConfig` is used as the golden path for sharing containers.

### SQS Resources

Open up your project's SAM [`template.yaml`](https://lamby.custominktech.com/docs/anatomy#file-template-yaml) file and make the following additions and changes. First, we need to create your [SQS queues](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sqs-queues.html) under the `Resources` section.

```yaml
JobsQueue:
  Type: AWS::SQS::Queue
  Properties:
    ReceiveMessageWaitTimeSeconds: 10
    RedrivePolicy:
      deadLetterTargetArn: !GetAtt JobsDLQueue.Arn
      maxReceiveCount: 13
    VisibilityTimeout: 301

JobsDLQueue:
  Type: AWS::SQS::Queue
  Properties:
    MessageRetentionPeriod: 1209600
```

In this example above we are also creating a queue to automatically handle our redrives and storage for any dead messages. We use [long polling](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html#sqs-long-polling) to receive messages for lower costs. In most cases your message is consumed almost immediately. Sidekiq polling is around 10s too.

The max receive count is 13 which means you get 12 retries. This is done so we can mimic Sidekiq's [automatic retry and backoff](https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry). The dead letter queue retains messages for the maximum of 14 days. This can be changed as needed. We also make no assumptions on how you want to handle dead jobs.

### Queue Name Environment Variable

We need to pass the newly created queue's name as an environment variable to your soon to be created jobs function. Since it is common for your Rails web and jobs functions to share these, we can leverage [SAM's Globals](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-specification-template-anatomy-globals.html) section.

```yaml
Globals:
  Function:
    Environment:
      Variables:
        RAILS_ENV: !Ref RailsEnv
        JOBS_QUEUE_NAME: !GetAtt JobsQueue.QueueName
```

We can remove the `Environment` section from our web function and all functions in this stack will now use the globals. Here we are using an [intrinsic function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-getatt.html) to pass the queue's name as the `JOBS_QUEUE_NAME` environment variable.

### IAM Permissions

Both functions will need capabilities to access the SQS jobs queue. We can add or extend the [SAM Policies](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-function.html#sam-function-policies) section of our `RailsLambda` web function so it (and our soon to be created jobs function) have full capabilities to this new queue.

```yaml
Policies:
  - Version: "2012-10-17"
    Statement:
      - Effect: Allow
        Action:
          - sqs:*
        Resource:
          - !Sub arn:aws:sqs:${AWS::Region}:${AWS::AccountId}:${JobsQueue.QueueName}
```

### Overview

Now we can duplicate our `RailsLambda` resource YAML (except for the `Events` property) to a new `JobsLambda` one. This gives us a distinct Lambda function to process jobs whose events, memory, timeout, and more can be independently tuned. However, both the `web` and `jobs` functions will use the same ECR container image!

```yaml
JobsLambda:
  Type: AWS::Serverless::Function
  Metadata:
    DockerContext: ./.lamby/RailsLambda
    Dockerfile: Dockerfile
    DockerTag: jobs
  Properties:
    Events:
      SQSJobs:
        Type: SQS
        Properties:
          Queue: !GetAtt JobsQueue.Arn
          BatchSize: 1
          FunctionResponseTypes:
            - ReportBatchItemFailures
    ImageConfig:
      Command: ["config/environment.Lambdakiq.cmd"]
    MemorySize: 1792
    PackageType: Image
    Policies:
      - Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Action:
              - sqs:*
            Resource:
              - !Sub arn:aws:sqs:${AWS::Region}:${AWS::AccountId}:${JobsQueue.QueueName}
    Timeout: 300
```

Here are some key aspects of our `JobsLambda` resource above:

- We use the `ImageConfig.Command` to load your Rails env and invoke the `Lambdakiq.cmd` which calls the `Lambdakiq.handler` on your behalf.
- The `Events` property uses the [SQS Type](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-sqs.html).
- The [BatchSize](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-sqs.html#sam-function-sqs-batchsize) can be any number you like. Less means more Lambda concurrency, more means some jobs could take longer. The jobs function `Timeout` must be lower than the `JobsQueue`'s `VisibilityTimeout` property. When the batch size is one, the queue's visibility is generally one second more.
- You must use `ReportBatchItemFailures` response types. Lambdakiq assumes we are [reporting batch item failures](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#services-sqs-batchfailurereporting). This is a new feature of SQS introduced in [November 2021](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#services-sqs-batchfailurereporting).
- The `Metadata`'s Docker properties must be the same as our web function except for the `DockerTag`. This is needed for the image to be shared. This works around a known [SAM issue](https://github.com/aws/aws-sam-cli/issues/2466) vs using the `ImageConfig` property.

🎉 Deploy your application and have fun with ActiveJob on SQS & Lambda.

## Configuration

Most general Lambdakiq configuration options are exposed via the Rails standard configuration method.

### Rails Configs

```ruby
config.lambdakiq
```

- `max_retries=` - Retries for all jobs. Default is the Lambdakiq maximum of `12`.
- `metrics_namespace=` - The CloudWatch Embedded Metrics namespace. Default is `Lambdakiq`.
- `metrics_logger=` - Set to the Rails logger which is STDOUT via Lamby/Lambda.

### ActiveJob Configs

You can also set configuration options on a per job basis using the `lambdakiq_options` method.

```ruby
class OrderProcessorJob < ApplicationJob
  lambdakiq_options retry: 2
end
```

- `retry` - Overrides the default Lambdakiq `max_retries` for this one job.

## Observability with CloudWatch

Get ready to gain way more insights into your ActiveJobs using AWS' [CloudWatch](https://aws.amazon.com/cloudwatch/) service. Every AWS service, including SQS & Lambda, publishes detailed [CloudWatch Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html). This gem leverages [CloudWatch Embedded Metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format.html) to add detailed ActiveJob metrics to that system. You can mix and match these data points to build your own [CloudWatch Dashboards](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html). If needed, any combination can be used to trigger [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html). Much like Sumo Logic, you can search & query for data using [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html).

![CloudWatch Dashboard](https://user-images.githubusercontent.com/2381/106465990-be7a6200-6468-11eb-8461-93db0046cda5.png)

Metrics are published under the `Lambdakiq` namespace. This is configurable using `config.lambdakiq.metrics_namespace` but should not be needed since all metrics are published using these three dimensions which allow you to easily segment metrics/dashboards to a specific application.

### Metric Dimensions

- `AppName` - This is the name of your Rails application. Ex: `MyApp`
- `JobEvent` - Name of the ActiveSupport Notification. Ex: `*.active_job`.
- `JobName` - The class name of the ActiveSupport job. Ex: `NotificationJob`

### ActiveJob Event Names

For reference, here are the `JobEvent` names published by ActiveSupport. A few of these are instrumented by Lambdakiq since we use custom retry logic like Sidekiq. These event/metrics are found in the Rails application CloudWatch logs because they publish/enqueue jobs.

- `enqueue.active_job`
- `enqueue_at.active_job`

While these event/metrics can be found in the jobs function's log.

- `perform_start.active_job`
- `perform.active_job`
- `enqueue_retry.active_job`
- `retry_stopped.active_job`

### Metric Properties

These are the properties published with each metric. Remember, properties can not be used as metric data in charts but can be searched using [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html).

- `JobId` - ActiveJob Unique ID. Ex: `9f3b6977-6afc-4769-aed6-bab1ad9a0df5`
- `QueueName` - SQS Queue Name. Ex: `myapp-JobsQueue-14F18LG6XFUW5.fifo`
- `MessageId` - SQS Message ID. Ex: `5653246d-dc5e-4c95-9583-b6b83ec78602`
- `ExceptionName` - Class name of error raised. Present in perform and retry events.
- `EnqueuedAt` - When ActiveJob enqueued the message. Ex: `2021-01-14T01:43:38Z`
- `Executions` - The number of current executions. Counts from `1` and up.
- `JobArg#{n}` - Enumerated serialized arguments.

### Metric Data

And finally, here are the metrics which each dimension can chart using [CloudWatch Metrics & Dashboards](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html).

- `Duration` - Of the job event in milliseconds.
- `Count` - Of the event.
- `ExceptionCount` - Of the event. Useful with `ExceptionName`.

### CloudWatch Dashboard Examples

Please share how you are using CloudWatch to monitor and/or alert on your ActiveJobs with Lambdakiq!

💬 https://github.com/customink/lambdakiq/discussions/3

## Common Questions

**Are Scheduled Jobs Supported?** - No. If you need a scheduled job please use the [SAM Schedule](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-schedule.html) event source which invokes your function with an [Eventbridege AWS::Events::Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html).

**Are FIFO Queues Supported?** - Yes. When you create your [AWS::SQS::Queue](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sqs-queues.html) resources you can set the [FifoQueue](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-sqs-queues.html#aws-sqs-queue-fifoqueue) property to `true`. Remember that both your jobs queue and the redrive queue must be the same. When using FIFO we:

- Simulate `delay_seconds` for ActiveJob's wait by using visibility timeouts under the hood. We still cap it to non-FIFO's 15 minutes.
- Set both the messages `message_group_id` and `message_deduplication_id` to the unique job id provided by ActiveJob.

**Can I Use Multiple Queues?** - Yes. Nothing is stopping you from creating any number of queues and/or functions to process them. Your subclasses can use ActiveJob's `queue_as` method as needed. This is an easy way to handle job priorities too.

```ruby
class SomeLowPriorityJob < ApplicationJob
  queue_as ENV['BULK_QUEUE_NAME']
end
```

**What Is The Max Message Size?** - 256KB. ActiveJob messages should be small however since Rails uses the [GlobalID](https://github.com/rails/globalid) gem to avoid marshaling large data structures to jobs.

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
