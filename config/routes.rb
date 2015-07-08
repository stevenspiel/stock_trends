Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'syms#index'

  resources :syms do
    member do
      get :rerun_historical
      post :toggle_favorite
    end
    collection do
      get :autocomplete
      get :initialize_autocomplete
      get :favorites
    end
  end

  get 'disclaimer' => 'disclaimer#show'
end
