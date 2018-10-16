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
    # They need to be the owner or be an admin of an assigned group
    user.super_admin? or (user.admin? and
                          (record.owner_id == user.id or
                           not record.groups.find_by(admin_user_id: user.id).nil?))
  end

  def destroy?
    # Only admin users destroy projects
    # They need to be the owner of the project
    user.super_admin? or (user.admin? and record.owner_id == user.id)
  end

  def chown?
    user.super_admin?
  end

  def export?
    user.admin?
  end

  def submit?
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
