# encoding: utf-8
module PagSeguro
  module ApiPayment
    extend self

    API_URL = "https://ws.pagseguro.uol.com.br/v2/checkout/"

    # Normalize the specified hash converting all data to UTF-8.
    #
    def normalize(hash)
      each_value(hash) do |value|
        Utils.to_utf8(value)
      end
    end

    # Denormalize the specified hash converting all data to ISO-8859-1.
    #
    def denormalize(hash)
      each_value(hash) do |value|
        Utils.to_iso8859(value)
      end
    end

    # Send the ApiOrder information and get redirect url
    #
    def get_payment_response(api_order)
      # include the params to validate our request
      request_params = {
        :encoding => "UTF-8",
        :email => PagSeguro.config["email"],
        :token => PagSeguro.config["authenticity_token"],
        :currency => "BRL"
      }
      # <%= hidden_field_tag "tipo", "CP" %>

      api_order.products.each_with_index do |product, i|
        i += 1
        request_params.merge!({
          "itemQuantity#{i}".to_sym => product[:quantity],
          "itemId#{i}".to_sym => product[:id],
          "itemDescription#{i}".to_sym => product[:description],
          "itemAmount#{i}".to_sym => product[:price]          
        })
        request_params.merge!({
          "itemWeight#{i}".to_sym => product[:weight].to_i
        }) if product[:weight]
      end

      api_order.billing.each do |name, value|
        request_params.merge!({
          PagSeguro::ApiOrder::BILLING_MAPPING[name.to_sym].to_sym => value
        })
      end

      # add optional values if available
      request_params.merge!({:reference => api_order.id}) if api_order.id
      request_params.merge!({:shippingType => api_order.shipping_type}) if api_order.shipping_type
      request_params.merge!({:extraAmount => api_order.extra_amount}) if api_order.extra_amount
      request_params.merge!({:redirectURL => api_order.redirect_url}) if api_order.redirect_url
      request_params.merge!({:maxUses => api_order.max_uses}) if api_order.max_uses
      request_params.merge!({:maxAge => api_order.max_age}) if api_order.max_age
      
      # do the request
      uri = URI.parse(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.ca_file = File.dirname(__FILE__) + "/cacert.pem"

      request = Net::HTTP::Post.new(uri.path)
      request.form_data = denormalize(request_params)
      response = http.start {|r| r.request request }
      
      #return the request
      response
    end
    
    private
    def each_value(hash, &blk) # :nodoc:
      hash.each do |key, value|
        if value.kind_of?(Hash)
          hash[key] = each_value(value, &blk)
        else
          hash[key] = blk.call value
        end
      end

      hash
    end
  end
end
