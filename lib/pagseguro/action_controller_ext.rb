module PagSeguro
  module ActionController
    private
      def pagseguro_notification(&block)
        return unless request.post?
        
        _notification = PagSeguro::Notification.new(params)
        yield _notification if _notification.valid?
      end
  end
end
