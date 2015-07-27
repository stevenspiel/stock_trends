Rails.application.routes.draw do
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]

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
