
# Lambdakiq

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
