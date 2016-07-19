class VideoGameResource < ApplicationResource
  attributes :title

  has_one :user

  before_create { _model.user = current_user }

  def self.creatable_fields(context)
    super - [:user]
  end

  def self.updatable_fields(context)
    super - [:user]
  end

  def self.records(options = {})
    user = current_user(options)
    VideoGame.for_user_and_followed(user)
  end
end
