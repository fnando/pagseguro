module PagSeguro
  class Notification
    API_URL = "https://pagseguro.uol.com.br/Security/NPI/Default.aspx"

    # Map all the attributes from PagSeguro
    MAPPING = {
      :payment_method => "TipoPagamento",
      :order_id       => "Referencia",
      :processed_at   => "DataTransacao",
      :status         => "StatusTransacao",
      :transaction_id => "TransacaoID",
      :shipping_type  => "TipoFrete",
      :shipping       => "ValorFrete",
      :notes          => "Anotacao"
    }

    # Map order status from PagSeguro
    STATUS = {
      "Completo"          => :completed,
      "Aguardando Pagto"  => :pending,
      "Aprovado"          => :approved,
      "Em Análise"        => :verifying,
      "Cancelado"         => :canceled,
      "Devolvido"         => :refunded
    }

    # Map payment method from PagSeguro
    PAYMENT_METHOD = {
      "Cartão de Crédito" => :credit_card,
      "Boleto"            => :invoice,
      "Pagamento"         => :pagseguro,
      "Pagamento online"  => :online_transfer
    }

    # The Rails params hash
    attr_accessor :params

    # Expects the params object from the current request
    def initialize(params, token = nil)
      @token = token
      @params = normalize(params)
    end

    # Normalize the specified hash converting all data to UTF-8
    def normalize(hash)
      each_value(hash) do |value|
        value.to_s.unpack('C*').pack('U*')
      end
    end

    # Denormalize the specified hash converting all data to ISO-8859-1
    def denormalize(hash)
      each_value(hash) do |value|
        value.to_s.unpack('U*').pack('C*')
      end
    end

    # Return a local URL if developer mode is enabled; this URL
    # will always respond "VERIFICADO" in this case
    def api_url
      if PagSeguro.developer?
        File.join PagSeguro.config["base"], "pagseguro_developer/confirm"
      else
        API_URL
      end
    end

    # Return a list of products sent by PagSeguro.
    # The values will be normalized
    # (e.g. currencies will be converted to cents, quantity will be an integer)
    def products
      @products ||= begin
        items = []

        for i in (1..params["NumItens"].to_i)
          items << {
            :id => params["ProdID_#{i}"],
            :description => params["ProdDescricao_#{i}"],
            :quantity => params["ProdQuantidade_#{i}"].to_i,
            :price => to_price(params["ProdValor_#{i}"]),
            :shipping => to_price(params["ProdFrete_#{i}"]),
            :fees => to_price(params["ProdExtras_#{i}"])
          }
        end

        items
      end
    end

    # Return the shipping fee
    # Will be converted to a float number
    def shipping
      to_price mapping_for(:shipping)
    end

    # Return the order status
    # Will be mapped to the STATUS constant
    def status
      @status ||= STATUS[mapping_for(:status)]
    end

    # Return the payment method
    # Will be mapped to the PAYMENT_METHOD constant
    def payment_method
      @payment_method ||= PAYMENT_METHOD[mapping_for(:payment_method)]
    end

    # Parse the processing date to a Ruby object
    def processed_at
      @processed_at ||= begin
        groups = *mapping_for(:processed_at).match(/(\d{2})\/(\d{2})\/(\d{4}) ([\d:]+)/sm)
        Time.parse("#{groups[3]}-#{groups[2]}-#{groups[1]} #{groups[4]}")
      end
    end

    # Return the buyer info
    def buyer
      @buyer ||= {
        :name    => params["CliNome"],
        :email   => params["CliEmail"],
        :phone   => {
          :area_code => params["CliTelefone"].to_s.split(" ").first,
          :number => params["CliTelefone"].to_s.split(" ").last
        },
        :address => {
          :street => params["CliEndereco"],
          :number => params["CliNumero"],
          :complements => params["CliComplemento"],
          :neighbourhood => params["CliBairro"],
          :city => params["CliCidade"],
          :state => params["CliEstado"],
          :postal_code => params["CliCEP"]
        }
      }
    end

    def method_missing(method, *args)
      return mapping_for(method) if MAPPING[method]
      super
    end

    # A wrapper to the params hash,
    # sanitizing the return to symbols
    def mapping_for(name)
      params[MAPPING[name]]
    end

    # Cache the validation.
    # To bypass the cache, just provide an argument that is evaluated as true.
    #
    #   invoice.valid?
    #   invoice.valid?(:nocache)
    def valid?(force=false)
      @valid = nil if force
      @valid = validates? if @valid.nil?
      @valid
    end

    private
      def each_value(hash, &blk)
        hash.each do |key, value|
          if value.kind_of?(Hash)
            hash[key] = each_value(value, &blk)
          else
            hash[key] = blk.call value
          end
        end

        hash
      end

      # Convert amount format to float
      def to_price(amount)
        amount.to_s.gsub(/[^\d]/, "").gsub(/^(\d+)(\d{2})$/, '\1.\2').to_f
      end

      # Check if the provided data is valid by requesting the
      # confirmation API url.
      def validates?
        # include the params to validate our request
        request_params = denormalize params.merge({
          :Comando => "validar",
          :Token => @token || PagSeguro.config["authenticity_token"]
        }).dup

        return true if PagSeguro.developer?

        # do the request
        uri = URI.parse(API_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data request_params
        response = http.start {|r| r.request request }
        (response.body =~ /VERIFICADO/) != nil
      end
  end
end
