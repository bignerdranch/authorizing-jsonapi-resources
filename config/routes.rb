Rails.application.routes.draw do
  use_doorkeeper
  jsonapi_resources :video_games
end
