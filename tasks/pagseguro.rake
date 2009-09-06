namespace :pagseguro do
  desc "Send notification to the URL specified in your config/pagseguro.yml file"
  task :notify do
    require "config/environment"
    require File.dirname(__FILE__) + "/../init"
    require File.dirname(__FILE__) + "/../lib/pagseguro/rake"
    PagSeguro::Rake.run
  end
  
  desc "Copy configuration file"
  task :setup do
    require "FileUtils" unless defined?(FileUtils)
    FileUtils.cp File.dirname(__FILE__) + "/../templates/pagseguro.yml", "config/pagseguro.yml"
    
    puts "=> [PagSeguro] Please edit 'config/pagseguro.yml'"
  end
end
