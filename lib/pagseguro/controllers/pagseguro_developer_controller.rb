class PagseguroDeveloperController < ApplicationController
  skip_before_filter :verify_authenticity_token
  PAGSEGURO_ORDERS_FILE = File.join(Rails.root, "tmp", "pagseguro-#{RAILS_ENV}.yml")
  
  def create
    require "FileUtils" unless defined?(FileUtils)
    
    # create the orders file if doesn't exist
    FileUtils.touch(PAGSEGURO_ORDERS_FILE) unless File.exist?(PAGSEGURO_ORDERS_FILE)
    
    # YAML caveat: if file is empty false is returned;
    # we need to set default to an empty hash in this case
    orders = YAML.load_file(PAGSEGURO_ORDERS_FILE) || {}
    
    # add a new order, associating it to the order id
    orders[params[:ref_transacao]] = params.except(:controller, :action, :only_path, :authenticity_token)
    
    # save the file
    File.open(PAGSEGURO_ORDERS_FILE, "w+") do |f|
      f << orders.to_yaml
    end
    
    # redirect to the configuration url
    redirect_to PagSeguro.config["return_to"]
  end
end
