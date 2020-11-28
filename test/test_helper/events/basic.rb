module TestHelpers
  module Events
    class Basic < Base

      self.event = {
        "Records" => [
          {
            "messageId" => "c42c6b3a-1c01-48eb-8934-aeb4e0638aa7",
            "receiptHandle" => "AQEBsQ60u/KXaRcorTDrqJ6zTs/p5nQ9Bbym4JSTvoW6g4dTMReChX5Quh3OP/+34ZFSgGKCwN8MixfUFag+SCc/SSFcZoBqbPAjHktQ00BnVemjYZp8fS3xHOjczjPNW2Ds1k5ijZn1v+zxwWtzSKSVSAQJVneh0+4p0zfXehKvlQWI8mYIm7ixdml1zPanosbOn50njp3eN6DGOx0QLPwYELViDv0/zSIzSxfsac0jw2waO1o1jtsU87XJ25v46TlBeuGhMKFmJ6fkiUNqTtx75v6FXtbM16W21Jhw6Tbh6+Q=",
            "body" => "{\"job_class\" =>\"KiqitJob\",\"job_id\" =>\"24a293dd-18b6-4f07-aa45-337589956826\",\"provider_job_id\" =>null,\"queue_name\" =>\"lambdakiq-jobs.fifo\",\"priority\" =>null,\"arguments\" =>[83],\"executions\" =>0,\"exception_executions\" =>{},\"locale\" =>\"en\",\"timezone\" =>\"UTC\",\"enqueued_at\" =>\"2020-11-28T03 =>03 =>00Z\"}",
            "attributes" => {
              "ApproximateReceiveCount" => "1",
              "SentTimestamp" => "1606532580760",
              "SequenceNumber" => "18858016414384115456",
              "MessageGroupId" => "ShoryukenMessage",
              "SenderId" => "AROA4DJKY67RIRD72L5DE",
              "MessageDeduplicationId" => "6f872995370771f172e98af04e09267266f0b618e0d0486c140023afaf689c08",
              "ApproximateFirstReceiveTimestamp" => "1606532580760"
            },
            "messageAttributes" => {
              "shoryuken_class" => {
                "stringValue" => "ActiveJob => =>QueueAdapters => =>ShoryukenAdapter => =>JobWrapper",
                "stringListValues" => [

                ],
                "binaryListValues" => [

                ],
                "dataType" => "String"
              }
            },
            "md5OfBody" => "f903390c94cdcca2443b8d0e86422edb",
            "md5OfMessageAttributes" => "ff41d67aace8f6c385e8a5071b828b5c",
            "eventSource" => "aws =>sqs",
            "eventSourceARN" => "arn =>aws =>sqs =>us-east-1 =>831702759394 =>lambdakiq-jobs.fifo",
            "awsRegion" => "us-east-1"
          }
        ]
      }.freeze

    end
  end
end
