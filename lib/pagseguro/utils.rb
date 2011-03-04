module PagSeguro
  module Utils
    extend self

    def encode(string)
      if PagSeguro.utf8?
        string
      else
        to_iso8859(string)
      end
    end

    def to_utf8(string)
      string.to_s.unpack('C*').pack('U*')
    end

    def to_iso8859(string)
      string.to_s.unpack('U*').pack('C*')
    end
  end
end
