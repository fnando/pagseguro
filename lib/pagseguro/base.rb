module PagSeguro
  extend self

  # PagSeguro receives all invoices in this URL. If developer mode is enabled,
  # then the URL will be /pagseguro_developer/invoice
  GATEWAY_URL = "https://pagseguro.uol.com.br/security/webpagamentos/webpagto.aspx"

  # Hold the config/pagseguro.yml contents
  @@config = nil

  # The path to the configuration file
  def config_file
    Rails.root.join("config/pagseguro.yml")
  end

  # Check if configuration file exists.
  def config?
    File.exist?(config_file)
  end

  # Load configuration file.
  def config
    raise MissingConfigurationError, "file not found on #{config_file.inspect}" unless config?

    # load file if is not loaded yet
    @@config ||= YAML.load_file(config_file)

    # raise an exception if the environment hasn't been set
    # or if file is empty
    if @@config == false || !@@config[Rails.env]
      raise MissingEnvironmentError, ":#{Rails.env} environment not set on #{config_file.inspect}"
    end

    # retrieve the environment settings
    @@config[Rails.env]
  end

  # The gateway URL will point to a local URL is
  # app is running in developer mode
  def gateway_url
    if developer?
      "/pagseguro_developer"
    else
      GATEWAY_URL
    end
  end

  # Reader for the `developer` configuration
  def developer?
    config? && config["developer"] == true
  end

  class MissingEnvironmentError < StandardError; end
  class MissingConfigurationError < StandardError; end
end
