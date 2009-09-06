require File.dirname(__FILE__) + "/lib/pagseguro"

if defined?(Rails)
  %w(action_controller_ext helper).each do |f|
    require File.dirname(__FILE__) + "/lib/pagseguro/#{f}"
  end
  
  ActionView::Base.send(:include, PagseguroHelper)
  ActionController::Base.send(:include, PagSeguro::ActionController)
end
