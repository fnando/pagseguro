require "net/https"
require "uri"
require "time"

%w(notification order).each do |f|
  require File.join(File.dirname(__FILE__), "pagseguro", f)
end

module PagSeguro
  extend self
  
  # The path to the configuration file
  if defined?(Rails)
    CONFIG_FILE = File.join(Rails.root, "config", "pagseguro.yml")
  else
    CONFIG_FILE = "config/pagseguro.yml"
  end
  
  # PagSeguro receives all invoices in this URL. If developer mode is enabled,
  # then the URL will be /pagseguro_developer/invoice
  GATEWAY_URL = "https://pagseguro.uol.com.br/security/webpagamentos/webpagto.aspx"
  
  # Hold the config/pagseguro.yml contents
  @@config = nil
  
  # Initialize the developer mode if `developer`
  # configuration is set
  def init!
    # check if configuration file is already created
    unless File.exist?(CONFIG_FILE)
      puts "=> [PagSeguro] The configuration could not be found at #{CONFIG_FILE.inspect}"
      return
    end
    
    # The developer mode is enabled? So install it!
    developer_mode_install! if developer?
  end
  
  # The gateway URL will point to a local URL is
  # app is running in developer mode
  def gateway_url
    if developer?
      File.join "/pagseguro_developer/create"
    else
      GATEWAY_URL
    end
  end
  
  # Reader for the `developer` configuration
  def developer?
    config["developer"] == true
  end
  
  # The developer mode install will add a controller to the
  # load path and set the URL routing to /pagseguro_developer/:action/:id
  # For now, there are only 1 action available: create
  def developer_mode_install!
    controller_path = File.dirname(__FILE__) + "/pagseguro/controllers"
    
    $LOAD_PATH << controller_path
    
    if defined?(ActiveSupport::Dependencies)
      ActiveSupport::Dependencies.load_paths << controller_path
    elsif defined?(Dependencies.load_paths)
      Dependencies.load_paths << controller_path
    else
      puts "=> [PagSeguro] Rails version too old for developer mode to work" and return
    end
    
    ::ActionController::Routing::RouteSet.class_eval do
      next if defined?(draw_with_pagseguro_map)
      
      def draw_with_pagseguro_map
        draw_without_pagseguro_map do |map|
          map.named_route "pagseguro_developer", 
            "/pagseguro_developer/:action/:id",
            :controller => "pagseguro_developer"
          
          yield map
        end
      end
      
      alias_method_chain :draw, :pagseguro_map
    end
  end
  
  def config
    raise MissingConfigurationException, "file not found on #{CONFIG_FILE.inspect}" unless File.exist?(CONFIG_FILE)
    
    # load file if is not loaded yet
    @@config ||= YAML.load_file(CONFIG_FILE)

    # raise an exception if the environment hasn't been set 
    # or if file is empty
    if @@config == false || !@@config[RAILS_ENV]
      raise MissingEnvironmentException, ":#{RAILS_ENV} environment not set on #{CONFIG_FILE.inspect}"
    end

    # retrieve the environment settings
    @@config[RAILS_ENV]
  end
  
  # exceptions
  class MissingEnvironmentException < StandardError; end
  class MissingConfigurationException < StandardError; end
end

PagSeguro.init!
