RailsEngine::Engine.routes.draw do
  devise_for :without_router,
    class_name: 'RailsEngine::User',
    module: :devise

  devise_for :with_router,
    class_name: 'RailsEngine::User',
    router_name: :rails_engine,
    module: :devise

  root to: 'with_router#index'
end
