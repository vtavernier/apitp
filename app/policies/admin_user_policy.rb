class AdminUserPolicy < ApplicationPolicy
  def index?
    # Ok to show all admins
    user.admin?
  end

  def show?
    # Ok to show all admin details
    user.admin? and super
  end

  def create?
    # No admin user creation
    false
  end

  def update?
    # Only update self
    @user == @record
  end

  def destroy?
    # Don't destroy admins
    false
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
