# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pagseguro/version"

Gem::Specification.new do |s|
  s.name        = "pagseguro"
  s.version     = PagSeguro::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/pagseguro"
  s.summary     = "The official PagSeguro library"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rails"        , "~> 3.0.5"
  s.add_development_dependency "fakeweb"      , "~> 1.3.0"
  s.add_development_dependency "rspec-rails"  , "~> 2.5.0"
  s.add_development_dependency "nokogiri"     , "~> 1.4.4"
  s.add_development_dependency "sqlite3-ruby" , "~> 1.3.3"
  s.add_development_dependency "ruby-debug19" if RUBY_VERSION >= "1.9"
end
