class User < ApplicationRecord
  has_secure_password

  has_many :video_games

  has_many :follows, foreign_key: :follower_id
  has_many :following, through: :follows, source: :followed

  has_many :following_video_games,
    through: :following,
    source: :video_games
end
