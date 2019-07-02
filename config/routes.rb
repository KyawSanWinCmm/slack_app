Rails.application.routes.draw do

  get 'star' => 't_direct_star_msg#create'
  get 'unstar' => 't_direct_star_msg#destroy'

  get 'starthread' => 't_direct_star_thread#create'
  get 'unstarthread' => 't_direct_star_thread#destroy'

  get 'groupstar' => 't_group_star_msg#create'
  get 'groupunstar' => 't_group_star_msg#destroy'

  get 'groupstarthread' => 't_group_star_thread#create'
  get 'groupunstarthread' => 't_group_star_thread#destroy'
  
  get 'channel' 'm_channels/new'
  get 'channel' 'm_channels/show'

  post 'directmsg' => 'direct_message#show'
  post 'directthreadmsg' => 'direct_message#showthread'
  

  post 'groupmsg' => 'group_message#show'
  post 'groupthreadmsg' => 'group_message#showthread'

  get 'sessions/new'
  get 'm_users/new'
  root 'static_pages#welcome'
  get '/welcome' => 'static_pages#welcome'

  get'/workspace' => 'm_workspaces#new'

  get 'welcome' => 'static_pages#welcome'
  get 'home' =>  'static_pages#home'
  get    '/signin' =>  'sessions#new'
  post   '/signin' =>  'sessions#create'
  delete '/logout' =>  'sessions#destroy'

  get 'home' => 'static_pages/home'

  resources :m_workspaces

  resources :m_users

  resources :m_channels

  resources :t_direct_messages
  resources :t_group_messages

  resources :account_activations, only: [:edit]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
