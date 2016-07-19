class VideoGameResource < ApplicationResource
  attributes :title

  has_one :user
end
