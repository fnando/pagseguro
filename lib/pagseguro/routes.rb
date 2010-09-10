Rails.application.routes.draw do
  get "pagseguro_developer/confirm", :to => "pag_seguro/developer#confirm"
  post "pagseguro_developer", :to => "pag_seguro/developer#create"
end
