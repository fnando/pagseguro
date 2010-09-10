module PagSeguro
  module ActionController
    private
    def pagseguro_notification(token = nil, &block)
      return unless request.post?

      notification = PagSeguro::Notification.new(params, token)
      yield notification if notification.valid?
    end
  end
end
