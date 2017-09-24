class ProjectPolicy < ApplicationPolicy
  def index?
    # Anyone can index projects
    true
  end

  def show?
    # Project must exist in user scope
    # Note: this is taken care of by the scope and a RecordNotFound
    true
  end

  def create?
    # Only admin users create projects
    user.admin?
  end

  def update?
    # Only admin users update projects
    user.super_admin? or (user.admin? and record.owner_id == user.id)
  end

  def destroy?
    # Only admin users destroy projects
    user.super_admin? or (user.admin? and record.owner_id == user.id)
  end

  def chown?
    user.super_admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.user(user).started
      end
    end
  end
end
