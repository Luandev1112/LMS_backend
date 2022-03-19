Rails.application.routes.draw do

  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             },
             defaults: {
               format: :json
             }
  devise_scope :user do
      get 'users/current', to: 'sessions#show'
  end

  resources :language_users, only: [:index, :create, :destroy]
  resources :saved_profiles, only: [:index, :create, :destroy]
  resources :student_subjects, only: [:index, :create, :destroy]
  resources :subject_tutors, only: [:index, :create, :destroy]
  resources :tutor_availabilities, only: [:index, :create, :destroy]
  resources :tutors, only: [:update] do 
    post 'search', on: :collection
  end
  resources :messages, only: [:create, :update, :destroy] do
    post 'search', on: :collection
  end
  
  root to: "home#index"
end
