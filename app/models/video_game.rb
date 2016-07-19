class VideoGame < ApplicationRecord
  belongs_to :user

  scope :for_user_and_followed, ->(user) {
    user_ids = [user.id] + user.following.pluck(:id)
    where(user_id: user_ids)
  }
end
