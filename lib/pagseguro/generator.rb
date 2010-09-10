require "rails/generators/base"

module PagSeguro
  class InstallGenerator < ::Rails::Generators::Base
    namespace "pagseguro:install"
    source_root File.dirname(__FILE__) + "/../../templates"

    def copy_configuration_file
      copy_file "config.yml", "config/pagseguro.yml"
    end
  end
end
