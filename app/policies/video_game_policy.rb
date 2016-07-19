class VideoGamePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.for_user_and_followed(user)
    end
  end
end
