module PagSeguro
  module Rake
    extend self

    def run
      require "digest/md5"

      env = ENV.inject({}) do |buffer, (name, value)|
        value = value.respond_to?(:force_encoding) ? value.dup.force_encoding("UTF-8") : value
        buffer.merge(name => value)
      end

      # Not running in developer mode? Exit!
      unless PagSeguro.developer?
        puts "=> [PagSeguro] Can only notify development URLs"
        puts "=> [PagSeguro] Double check your config/pagseguro.yml file"
        exit 1
      end

      # There's no orders file! Exit!
      unless File.exist?(PagSeguro::DeveloperController::PAGSEGURO_ORDERS_FILE)
        puts "=> [PagSeguro] No orders added. Exiting now!"
        exit 1
      end

      # Load the orders file
      orders = YAML.load_file(PagSeguro::DeveloperController::PAGSEGURO_ORDERS_FILE)

      # Ops! No orders added! Exit!
      unless orders
        puts "=> [PagSeguro] No invoices created. Exiting now!"
        exit 1
      end

      # Get the specified order
      order = orders[env["ID"]]

      # Not again! No order! Exit!
      unless order
        puts "=> [PagSeguro] The order #{env['ID'].inspect} could not be found. Exiting now!"
        exit 1
      end

      # Set the client's info
      name = env.fetch("NAME", Faker.name)
      email = env.fetch("EMAIL", Faker.email)

      order["CliNome"] = name
      order["CliEmail"] = email
      order["CliEndereco"] = Faker.street_name
      order["CliNumero"] = rand(1000)
      order["CliComplemento"] = Faker.secondary_address
      order["CliBairro"] = Faker.city
      order["CliCidade"] = Faker.city
      order["CliCEP"] = Faker.zipcode
      order["CliTelefone"] = Faker.phone_number

      # Set the transaction date
      order["DataTransacao"] = Time.now.strftime("%d/%m/%Y %H:%M:%S")

      # Replace the order id to the correct name
      order["Referencia"] = order.delete("ref_transacao")

      # Count the number of products in this order
      order["NumItens"] = order.inject(0) do |count, (key, value)|
        count += 1 if key =~ /item_id_/
        count
      end

      to_price = proc do |price|
        if price.to_s =~ /^(.*?)(.{2})$/
          "#{$1},#{$2}"
        else
          "0,00"
        end
      end

      for index in (1..order["NumItens"])
        order["ProdID_#{index}"] = order.delete("item_id_#{index}")
        order["ProdDescricao_#{index}"] = order.delete("item_descr_#{index}")
        order["ProdValor_#{index}"] = to_price.call(order.delete("item_valor_#{index}"))
        order["ProdQuantidade_#{index}"] = order.delete("item_quant_#{index}")
        order["ProdFrete_#{index}"] = to_price.call(order.delete("item_frete_#{index}"))
        order["ProdExtras_#{index}"] = "0,00"
      end

      # Retrieve the specified status or default to :completed
      status = env.fetch("STATUS", :completed).to_sym

      # Retrieve the specified payment method or default to :credit_card
      payment_method = env.fetch("PAYMENT_METHOD", :credit_card).to_sym

      # Set a random transaction id
      order["TransacaoID"] = Digest::MD5.hexdigest(Time.now.to_s)

      # Set note
      order["Anotacao"] = env["NOTE"].to_s

      # Retrieve index
      index = proc do |hash, value|
        if hash.respond_to?(:key)
          hash.key(value)
        else
          hash.index(value)
        end
      end

      # Set payment method and status
      order["TipoPagamento"] = index[PagSeguro::Notification::PAYMENT_METHOD, payment_method]
      order["StatusTransacao"] = index[PagSeguro::Notification::STATUS, status]

      # Finally, ping the configured return URL
      uri = URI.parse File.join(PagSeguro.config["base"], PagSeguro.config["return_to"])
      Net::HTTP.post_form uri, order
    end
  end
end
