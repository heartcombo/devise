Rails.application.routes.draw do
  devise_for :users

  get "dashboard", to: "home#dashboard"
  root "home#index"
end
