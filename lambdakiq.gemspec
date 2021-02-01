lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lambdakiq/version'

Gem::Specification.new do |spec|
  spec.name          = "lambdakiq"
  spec.version       = Lambdakiq::VERSION
  spec.authors       = ["Ken Collins"]
  spec.email         = ["kcollins@customink.com"]
  spec.summary       = %q{Scalable Rails Background Processing with AWS Lambda & SQS.}
  spec.description   = %q{Scalable Rails Background Processing with AWS Lambda & SQS.}
  spec.homepage      = "https://github.com/customink/lambdakiq"
  spec.license       = "MIT"
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|images)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency 'activejob'
  spec.add_dependency 'aws-sdk-sqs'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'railties'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'uuid'
end
