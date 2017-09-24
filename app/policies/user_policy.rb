class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    super
  end

  def create?
    user.admin?
  end

  def update?
    # Only update by admin or by self
    user.admin? or record.id == user.id
  end

  def destroy?
    # Only destroy by admin
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope
      else
        scope.where(id: record.id)
      end
    end
  end
end
