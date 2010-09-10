require "rspec/core/rake_task"
require File.dirname(__FILE__) + "/lib/pagseguro/version"

RSpec::Core::RakeTask.new

begin
  require "jeweler"

  JEWEL = Jeweler::Tasks.new do |gem|
    gem.name = "pagseguro"
    gem.version = PagSeguro::Version::STRING
    gem.summary = "A wrapper for the PagSeguro payment gateway."
    gem.description = ""
    gem.authors = ["Nando Vieira"]
    gem.email = "fnando.vieira@gmail.com"
    gem.homepage = "http://github.com/fnando/pagseguro"
    gem.has_rdoc = false
    gem.files = FileList["{.rspec,Gemfile,Gemfile.lock,Rakefile,README.markdown,pagseguro.gemspec}", "{lib,spec,templates,test}/**/*"]
    gem.add_development_dependency "rspec", ">= 2.0.0"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "You don't have Jeweler installed, so you won't be able to build gems."
end
