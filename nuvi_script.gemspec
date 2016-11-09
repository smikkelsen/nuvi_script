# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nuvi_script/version'

Gem::Specification.new do |spec|
  spec.name          = "nuvi_script"
  spec.version       = NuviScript::VERSION
  spec.authors       = ["Sean Mikkelsen"]
  spec.email         = ["sean@mikkelsenfam.com"]

  spec.summary       = %q{Small gem to scrape and endpoint for xml files and save them to redis}
  spec.description   = %q{This gem is for scraping a nuvi endpoint and publishing xml news feeds to a redis list}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'redis'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'rubyzip'
  spec.add_dependency 'ruby-progressbar'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
