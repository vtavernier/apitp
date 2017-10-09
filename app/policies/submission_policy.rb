class SubmissionPolicy < ApplicationPolicy
  def index?
    # No submission index
    false
  end

  def show?
    # Only show if admin or same user, or in team
    user.admin? or
        user.id == record.user_id or
        record.team.user_ids.include? user.id
  end

  def create?
    # Only users can create submissions for themselves,
    # for projects they are part of
    not user.admin? and
        user.id == record.user_id and
        not (user.group_ids & record.project.group_ids).empty?
        not scope.where(project_id: record.project_id,
                        user_id: record.user_id).exists?
  end

  def update?
    # Submissions cannot be updated
    false
  end

  def destroy?
    # Only an admin can delete the submission of a user
    # who is in a group the admin is administering
    user.admin? and
        (user.super_admin? or
            record.user.groups.where(admin_user_id: user.id).exists?)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
