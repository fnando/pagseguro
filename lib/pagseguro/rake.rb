module PagSeguro
  module Rake
    extend self

    def run
      require "digest/md5"

      # Not running in developer mode? Exit!
      unless PagSeguro.developer?
        puts "=> [PagSeguro] Can only notify development URLs"
        puts "=> [PagSeguro] Double check your config/pagseguro.yml file"
        exit
      end
      
      # There's no configuration file! Exit!
      unless File.exist?(PagseguroDeveloperController::PAGSEGURO_ORDERS_FILE)
        puts "=> [PagSeguro] No orders added. Exiting now!"
        exit
      end

      # Load the orders file
      orders = YAML.load_file(PagseguroDeveloperController::PAGSEGURO_ORDERS_FILE)
      
      # Ops! No orders added! Exit!
      unless orders
        puts "=> [PagSeguro] No invoices created. Exiting now!"
        exit
      end
      
      # Get the specified order
      order = orders[ENV["ID"]]
      
      # Not again! No order! Exit!
      unless order
        puts "=> [PagSeguro] The order #{ENV['ID'].inspect} could not be found. Exiting now!"
        exit
      end
      
      # Retrieve the specified status or default to :completed
      status = (ENV["STATUS"] || :completed).to_sym
      
      # Retrieve the specified payment method or default to :credit_card
      payment_method = (ENV["PAYMENT_METHOD"] || :credit_card).to_sym
      
      # Set a random transaction id
      order["TransacaoID"] = Digest::MD5.hexdigest(Time.now.to_s)
      
      # Set payment method and status
      order["TipoPagamento"] = PagSeguro::Notification::PAYMENT_METHOD.index(payment_method)
      order["StatusTransacao"] = PagSeguro::Notification::STATUS.index(status)
      
      # Count the number of products in this order
      order["NumItens"] = order.inject(0) do |count, (key, value)|
        count += 1 if key =~ /item_id_/
        count
      end
      
      # Finally, ping the configured return URL
      uri = URI.parse File.join(PagSeguro.config["base"], PagSeguro.config["return_to"])
      Net::HTTP.post_form uri, order
    end
  end
end
