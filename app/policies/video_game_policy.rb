class VideoGamePolicy < ApplicationPolicy

  def owned?
    record.user == user
  end

  alias_method :create?, :owned?
  alias_method :update?, :owned?
  alias_method :destroy?, :owned?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.for_user_and_followed(user)
    end
  end
end
