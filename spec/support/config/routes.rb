PagSeguro::Application.routes.draw do
  get "dashboard", :to => "dashboard#index"
  get "login", :to => "session#new"
end
