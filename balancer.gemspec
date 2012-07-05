# -*- encoding: utf-8 -*-
require File.expand_path('../lib/balancer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Trae Robrock"]
  gem.email         = ["trobrock@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "balancer"
  gem.require_paths = ["lib"]
  gem.version       = Balancer::VERSION

  gem.add_dependency %q<activesupport>, '~> 2.3.0'

  gem.add_development_dependency %q<rake>
  gem.add_development_dependency %q<rspec>
  gem.add_development_dependency %q<mocha>
end
