ENV["RAILS_ENV"] = "test"
require "rails"
require "fakeweb"
require "pagseguro"
require "bigdecimal"
require "support/config/boot"
require "rspec/rails"
require "support/matcher"

FakeWeb.allow_net_connect = false
