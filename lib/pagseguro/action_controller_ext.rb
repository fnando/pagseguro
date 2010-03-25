module PagSeguro
  module ActionController
    private
      def pagseguro_notification(token = nil, &block)
        return unless request.post?
        
        _notification = PagSeguro::Notification.new(params, token)
        yield _notification if _notification.valid?
      end
  end
end
