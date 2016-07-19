class VideoGameResource < ApplicationResource
  attributes :title

  has_one :user

  before_create { _model.user = current_user }

  before_create { authorize(_model, :create?) }
  before_update { authorize(_model, :update?) }
  before_remove { authorize(_model, :destroy?) }

  def self.creatable_fields(context)
    super - [:user]
  end

  def self.updatable_fields(context)
    super - [:user]
  end

  def self.records(options = {})
    user = current_user(options)
    Pundit.policy_scope!(user, VideoGame)
  end
end
