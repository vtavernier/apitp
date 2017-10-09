module UnicityConcern
  extend ActiveSupport::Concern

  included do
    def user_assignment_uniqueness
      unless user_assignment_unique?(self)
        errors.add(:groups, user_assignment_message(self))
      end
    end

    def project_assignment_uniqueness
      unless project_assignment_unique?(self)
        errors.add(:groups, project_assignment_message(self))
      end
    end

    def group_assignment_uniqueness
      unless group_assignment_unique?(self)
        errors.add(:users, group_assignment_message(self))
      end
    end

    private
      def user_assignment_unique?(user)
        count = assignment_unique_request('users.id = ?', user.id)[user.id]
        count.nil? or count == 1
      end

      def user_assignment_message(_user)
        I18n.t('unicity.user.non_unique')
      end

      def project_assignment_unique?(project)
        assignment_unique_request('assignments.project_id = ?', project.id).all? { |_user_id, count| count == 1 }
      end

      def project_assignment_message(project)
        I18n.t('unicity.project.non_unique', users: assignment_unique_names('assignments.project_id = ?', project.id).pluck(:name).join(", "))
      end

      def group_assignment_unique?(group)
        assignment_unique_request('users.id' => group.user_ids).all? { |_user_id, count| count == 1 }
      end

      def group_assignment_message(group)
        I18n.t('unicity.group.non_unique', users: assignment_unique_names('users.id' => group.user_ids).pluck(:name).join(", "))
      end

      def assignment_unique_request(*condition)
        assignment_unique_base(*condition)
            .group('assignments.project_id, users.id')
            .where(*condition)
            .count('assignments.id')
      end

      def assignment_unique_names(*condition)
        assignment_unique_base(*condition)
            .group('assignments.project_id, users.id, users.name')
            .having('COUNT(assignments.id) > 1')
            .where(*condition)
      end

      def assignment_unique_base(*condition)
        User.joins(:group_memberships)
            .joins('INNER JOIN assignments ON assignments.group_id = group_memberships.group_id')
      end
  end
end
