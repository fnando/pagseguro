ActionController::Routing::Routes.draw do |map|
  map.root :controller => "cart"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
