module PagSeguro
  module Rake
    extend self

    def run
      require "digest/md5"
      require "faker"

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

      # Set the client's info
      order["CliNome"] = ENV["NAME"] || Faker::Name.name
      order["CliEmail"] = Faker::Internet.email
      order["CliEndereco"] = Faker::Address.street_name
      order["CliNumero"] = rand(1000)
      order["CliComplemento"] = Faker::Address.secondary_address
      order["CliBairro"] = Faker::Address.city
      order["CliCidade"] = Faker::Address.city
      order["CliCEP"] = "12345678"
      order["CliTelefone"] = "11 12345678"
      
      # Set the transaction date
      order["DataTransacao"] = Time.now.strftime("%d/%m/%Y %H:%M:%S")
      
      # Replace the order id to the correct name
      order["Referencia"] = order.delete("ref_transacao")
      
      # Count the number of products in this order
      order["NumItens"] = order.inject(0) do |count, (key, value)|
        count += 1 if key =~ /item_id_/
        count
      end
      
      # Replace all products      
      to_price = lambda {|s| s.gsub(/^(.*?)(.{2})$/, '\1,\2') }
      
      for index in (1..order["NumItens"])
        order["ProdID_#{index}"] = order.delete("item_id_#{index}")
        order["ProdDescricao_#{index}"] = order.delete("item_descr_#{index}")
        order["ProdValor_#{index}"] = to_price.call(order.delete("item_valor_#{index}"))
        order["ProdQuantidade_#{index}"] = order.delete("item_quant_#{index}")
        order["ProdFrete_#{index}"] = order["item_frete_#{index}"] == "0" ? "0,00" : to_price.call(order.delete("item_frete_#{index}"))
        order["ProdExtras_#{index}"] = "0,00"
      end
      
      # Retrieve the specified status or default to :completed
      status = (ENV["STATUS"] || :completed).to_sym
      
      # Retrieve the specified payment method or default to :credit_card
      payment_method = (ENV["PAYMENT_METHOD"] || :credit_card).to_sym
      
      # Set a random transaction id
      order["TransacaoID"] = Digest::MD5.hexdigest(Time.now.to_s)
      
      # Set note
      order["Anotacao"] = ENV["NOTE"].to_s
      
      # Set payment method and status
      order["TipoPagamento"] = PagSeguro::Notification::PAYMENT_METHOD.index(payment_method)
      order["StatusTransacao"] = PagSeguro::Notification::STATUS.index(status)
      
      # Finally, ping the configured return URL
      uri = URI.parse File.join(PagSeguro.config["base"], PagSeguro.config["return_to"])
      Net::HTTP.post_form uri, order
    end
  end
end
