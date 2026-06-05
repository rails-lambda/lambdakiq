# Keep A Changelog!

See this http://keepachangelog.com link for information on how we want this formatted.

## v2.4.0

### Changed

- Update to Ruby 3.4.4 and Bundler 4.
- Update all gems, including Rails 6.1 → 8.1 and aws-sdk-sqs 1.35 → 1.116.
- Fix duplicate `JobName` key in CloudWatch metrics output (would raise an error in json 3.0).
- Modernize CI to use `ruby/setup-ruby` directly on `ubuntu-24.04`.
- Add `release.yml` workflow for trusted publishing to RubyGems.org.

## v2.3.0

### Added

Support `enqueue_after_transaction_commit?` for rails 7.2.

## v2.2.0

### Added

- Simple `Lambdakiq.cmd` to be used with `ImageConfig.Command`. 

## v2.1.0

#### Fixed

- Ensure failed messages go to DLQ. Fixes #30. Fixes #31. Thanks @thenano

## v2.0.2

#### Fixed

- Rails 5.1 oddities for class attribute default not set.

## v2.0.1

#### Fixed

- Rails 5.1 oddities for class attribute default not set.

## v2.0.0

#### Changed

- Leverage new `ReportBatchItemFailures` feature of SQS.

## v1.0.2, v1.0.3, v1.0.4

#### Fixed

- Rails v5.2 compatibility. Metrics logging is are safe for non-Lambdakiq jobs

## v1.0.0

#### Added

- Initial release.
