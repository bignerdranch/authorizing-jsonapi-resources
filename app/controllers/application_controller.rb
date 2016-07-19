class ApplicationController < JSONAPI::ResourceController
  before_action :doorkeeper_authorize!

  private

  def context
    {current_user: current_user}
  end

  def current_user
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
