class UserResource < ApplicationResource
  attribute :username
  attribute :email

  has_many :video_games
end
