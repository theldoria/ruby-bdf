# -*- encoding: utf-8 -*-

require File.expand_path('../lib/bdf/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "bdf"
  gem.version       = Bdf::VERSION
  gem.summary       = %q{Read BDF-Files}
  gem.description   = %q{Read bitmap font files in the Glyph Bitmap Distribution Format (BDF) from Adope.}
  gem.license       = "MIT"
  gem.authors       = ["Theldoria"]
  gem.email         = "theldoria@hotmail.com"
  gem.homepage      = "https://rubygems.org/gems/bdf"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
