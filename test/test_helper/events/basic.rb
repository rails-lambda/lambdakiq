module TestHelper
  module Events
    class Basic < Base

      self.event = JSON.load('
        {
            "Records": [
                {
                    "messageId": "9081fe74-bc79-451f-a03a-2fe5c6e2f807",
                    "receiptHandle": "AQEBgbn8GmF1fMo4z3IIqlJYymS6e7NBynwE+LsQlzjjdcKtSIomGeKMe0noLC9UDShUSe8bzr0s+pby03stHNRv1hgg4WRB5YT4aO0dwOuio7LvMQ/VW88igQtWmca78K6ixnU9X5Sr6J+/+WMvjBgIdvO0ycAM2tyJ1nxRHs/krUoLo/bFCnnwYh++T5BLQtFjFGrRkPjWnzjAbLWKU6Hxxr5lkHSxGhjfAoTCOjhi9crouXaWD+H1uvoGx/O/ZXaeMNjKIQoKjhFguwbEpvrq2Pfh2x9nRgBP3cKa9qw4Q3oFQ0MiQAvnK+UO8cCnsKtD",
                    "body": "{\"job_class\":\"TestHelper::Jobs::BasicJob\",\"job_id\":\"527cd37e-08f4-4aa8-9834-a46220cdc5a3\",\"provider_job_id\":null,\"queue_name\":\"lambdakiq-JobsQueue-TESTING123.fifo\",\"priority\":null,\"arguments\":[\"test\"],\"executions\":0,\"exception_executions\":{},\"locale\":\"en\",\"timezone\":\"UTC\",\"enqueued_at\":\"2020-11-30T13:07:36Z\"}",
                    "attributes": {
                        "ApproximateReceiveCount": "1",
                        "SentTimestamp": "1606741656429",
                        "SequenceNumber": "18858069937755376128",
                        "MessageGroupId": "527cd37e-08f4-4aa8-9834-a46220cdc5a3",
                        "SenderId": "AROA4DJKY67RBVYCN5UZ3",
                        "MessageDeduplicationId": "527cd37e-08f4-4aa8-9834-a46220cdc5a3",
                        "ApproximateFirstReceiveTimestamp": "1606741656429"
                    },
                    "messageAttributes": {
                        "lambdakiq": {
                            "stringValue": "1",
                            "stringListValues": [],
                            "binaryListValues": [],
                            "dataType": "String"
                        }
                    },
                    "md5OfMessageAttributes": "5fde2d817e4e6b7f28735d3b1725f817",
                    "md5OfBody": "6477b54fb64dde974ea7514e87d3b8a5",
                    "eventSource": "aws:sqs",
                    "eventSourceARN": "arn:aws:sqs:us-east-1:831702759394:lambdakiq-JobsQueue-TESTING123.fifo",
                    "awsRegion": "us-east-1"
                }
            ]
        }
      ').freeze

    end
  end
end
