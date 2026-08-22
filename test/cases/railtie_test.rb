require 'test_helper'
require 'shellwords'

class RailtieTest < LambdakiqSpec

  # The dummy app in this suite is already booted and Rails only initializes
  # once per process, so anything the railtie does during initialization has to
  # be exercised in a fresh process.
  def boot_app(config: '', check:)
    script = <<~RUBY
      require 'bundler/setup'
      require 'rails/all'
      require 'lambdakiq'
      require 'stringio'
      module BootCheck
        class Application < ::Rails::Application
          config.root = #{Dir.pwd.inspect}
          config.eager_load = false
          config.logger = ActiveSupport::Logger.new(StringIO.new)
          #{config}
        end
      end
      BootCheck::Application.initialize!
      puts(#{check})
    RUBY
    out = `ruby -I#{File.expand_path('lib')} -e #{Shellwords.escape(script)} 2>&1`
    [out.strip, $?.success?]
  end

  it 'defaults metrics_logger to the Rails logger' do
    out, ok = boot_app check: 'Lambdakiq.config.metrics_logger.equal?(Rails.logger)'
    assert ok, "boot failed:\n#{out}"
    expect(out).must_equal 'true'
  end

  it 'does not overwrite a metrics_logger set by the application' do
    out, ok = boot_app(
      config: 'config.lambdakiq.metrics_logger = ::MY_LOGGER = Logger.new(StringIO.new)',
      check: 'Lambdakiq.config.metrics_logger.equal?(::MY_LOGGER)'
    )
    assert ok, "boot failed:\n#{out}"
    expect(out).must_equal 'true'
  end

  it 'enables metrics by default' do
    out, ok = boot_app check: 'Lambdakiq.config.metrics_enabled'
    assert ok, "boot failed:\n#{out}"
    expect(out).must_equal 'true'
  end

  it 'honors metrics_enabled set by the application' do
    out, ok = boot_app(
      config: 'config.lambdakiq.metrics_enabled = false',
      check: 'Lambdakiq.config.metrics_enabled'
    )
    assert ok, "boot failed:\n#{out}"
    expect(out).must_equal 'false'
  end

end
