module PagSeguro
  class Order
    # The list of products added to the order
    attr_accessor :products
    
    # Define the shipping type.
    # Can be EN (PAC) or SD (Sedex)
    attr_accessor :shipping_type
    
    def initialize(order_id = nil)
      reset!
      self.id = order_id
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
    # - shipping (Optional. If float, will be multiplied by 100 cents)
    # - quantity (Optional. Defaults to 1)
    # - price (Required. If float, will be multiplied by 100 cents)
    # - description (Required. Identifies the product)
    # - id (Required. Should match the product on your database)
    # - fees (Optional. If float, will be multiplied by 100 cents)
    def <<(options)
      options = {
        :weight => nil,
        :shipping => nil,
        :fees => nil,
        :quantity => 1
      }.merge(options)
      
      # convert shipping to cents
      options[:shipping] = (options[:shipping] * 100).to_i if options[:shipping].kind_of?(Float)
      
      # convert fees to cents
      options[:fees] = (options[:fees] * 100).to_i if options[:fees].kind_of?(Float)
      
      # convert price to cents
      options[:price] = (options[:price] * 100).to_i if options[:price].kind_of?(Float)
      
      # convert weight to grammes
      options[:weight] = (options[:weight] * 1000).to_i if options[:weight].kind_of?(Float)
      
      products.push(options)
    end
    
    def add(options)
      self << options
    end
  end  
end
