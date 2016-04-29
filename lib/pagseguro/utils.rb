module PagSeguro
  module Utils
    extend self

    def to_utf8(string)
      string.to_s.unpack("C*").pack("U*")
    end

    def to_iso8859(string)
      string.to_s.unpack("U*").pack("C*")
    end
    
    def to_payment_url(string)
      string ? "https://pagseguro.uol.com.br/v2/checkout/payment.html?code=#{string}" : nil
    end
  end
end
