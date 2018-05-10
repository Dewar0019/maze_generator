Rails.application.routes.draw do
  resources :mazes, only: [:create] do
    member do
      get 'check'
      post 'solve'
    end
  end
end
