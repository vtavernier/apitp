class ProjectPolicy < ApplicationPolicy
  def index?
    # Anyone can index projects
    true
  end

  def show?
    # Project must exist in user scope
    super
  end

  def create?
    # Only admin users create projects
    user.admin?
  end

  def update?
    # Only admin users update projects
    # TODO: Admin owning project or super_admin?
    user.admin?
  end

  def destroy?
    # Only admin users destroy projects
    # TODO: Admin owning project or super_admin?
    user.admin?
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
