class VideoGameResource < ApplicationResource
  attributes :title

  has_one :user

  def self.records(options = {})
    user = current_user(options)
    user.video_games
  end
end
