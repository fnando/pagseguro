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
      :reference             => "reference"
    }

    # The list of products added to the order
    attr_accessor :products

    # The billing info that will be sent to PagSeguro.
    attr_accessor :billing

    # Define the shipping type.
    # Can be EN (PAC) or SD (Sedex)
    attr_accessor :shipping_type

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
    # - price (Required. If float, will be multiplied by 100 cents)
    # - description (Required. Identifies the product)
    # - id (Required. Should match the product on your database)
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