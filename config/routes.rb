Rails.application.routes.draw do
  resources :classifications

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  resources :users
  get 'lyrics_get' => 'classifications#get_lyric_link'
  post 'update_library' => 'classifications#update_song_library', as: :update_library_post
  get 'update_library' => 'visitors#update_library'

  get 'random_player' => 'visitors#random_player'
end
