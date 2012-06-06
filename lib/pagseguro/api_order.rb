module PagSeguro
  class ApiOrder
    # Map all billing attributes that will be added as form inputs.
    BILLING_MAPPING = {
      :name                  => "senderName",
      :email                 => "senderEmail",
      :phone_area_code       => "senderAreaCode",
      :phone_number          => "senderPhone",
      :address_zipcode       => "shippingAddressPostalCode",
      :address_street        => "shippingAddressStreet",
      :address_number        => "shippingAddressNumber",
      :address_complement    => "shippingAddressComplement",
      :address_neighbourhood => "shippingAddressDistrict",
      :address_city          => "shippingAddressCity",
      :address_state         => "shippingAddressState",
      :address_country       => "shippingAddressCountry",
    }

    # The list of products added to the order
    attr_accessor :products

    # The billing info that will be sent to PagSeguro.
    attr_accessor :billing

    # Optional: define the shipping type. Can be 1 (PAC) or 2 (Sedex)
    attr_accessor :shipping_type
    
    # Optional: extra amount on the purchase (negative for discount
    attr_accessor :extra_amount

    # Optional: specific redirect URL
    attr_accessor :redirect_url

    # Optional: order id in your system
    attr_accessor :reference

    # Optional: maximum number of uses of generated code, integer greater than 0
    attr_accessor :max_uses
    
    # Optional: maximum age of generated code in seconds, integer greater than 30
    attr_accessor :max_age
    
    def initialize(order_id = nil)
      reset!
      self.id = order_id
      self.billing = {}
    end

    # Set the order identifier. Should be a unique
    # value to identify this order on your own application
    def id=(identifier)
      @id = identifier
    end

    # Get the order identifier
    def id
      @id
    end

    # Remove all products from this order
    def reset!
      @products = []
    end

    # Add a new product to the PagSeguro order
    # The allowed values are:
    # - weight (Optional. If float, will be multiplied by 1000g)
    # - quantity (Optional. Defaults to 1)
    # - price (Required, can be float)
    # - description (Required. Identifies the product)
    # - id (Required. Should match the product on your database)
    # - shipping_cost(Optional. Will be used if provided instead
    #     of calculated by Correio)
    def <<(options)
      options = {
        :weight => nil,
        :quantity => 1
      }.merge(options)

      # convert weight to grammes
      options[:weight] = convert_unit(options[:weight], 1000)

      products.push(options)
    end

    def add(options)
      self << options
    end

    private
    def convert_unit(number, unit)
      number = (BigDecimal("#{number}") * unit).to_i unless number.nil? || number.kind_of?(Integer)
      number
    end
  end
end