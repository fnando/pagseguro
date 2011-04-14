module PagSeguro
  class Railtie < Rails::Railtie
    generators do
      require "pagseguro/generator"
    end

    initializer :add_routing_paths do |app|
      if PagSeguro.developer?
        app.routes_reloader.paths.unshift(File.dirname(__FILE__) + "/routes.rb")
      end
    end

    rake_tasks do
      load File.dirname(__FILE__) + "/../tasks/pagseguro.rake"
    end

    initializer "pagseguro.initialize" do |app|
      ::ActionView::Base.send(:include, PagSeguro::Helper)
      ::ActionController::Base.send(:include, PagSeguro::ActionController)

      app.paths.app.views << File.dirname(__FILE__) + "/views"
    end

    config.after_initialize do
      require "pagseguro/developer_controller" if PagSeguro.developer?
    end
  end
end
