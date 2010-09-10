namespace :pagseguro do
  desc "Send notification to the URL specified in your config/pagseguro.yml file"
  task :notify => :environment do
    PagSeguro::Rake.run
  end
end
