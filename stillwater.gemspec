# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stillwater/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Trae Robrock", "Julio Santos"]
  gem.email         = ["trobrock@gmail.com"]
  gem.description   = %q{A simple connection pool, that allows connections to different servers (or anything else)}
  gem.summary       = %q{A simple connection pool, that allows connections to different servers (or anything else)}
  gem.homepage      = "https://github.com/trobrock/stillwater"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stillwater"
  gem.require_paths = ["lib"]
  gem.version       = Stillwater::VERSION

  gem.add_development_dependency %q<rake>
  gem.add_development_dependency %q<rspec>
  gem.add_development_dependency %q<mocha>
end
