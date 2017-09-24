class GroupPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? and super
  end

  def create?
    user.admin?
  end

  def update?
    # Only the group admin can edit
    user.admin? and (user.super_admin? or record.admin_user_id == user.id)
  end

  def destroy?
    # Only the group admin can destroy
    user.admin? and (user.super_admin? or record.admin_user_id == user.id)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
