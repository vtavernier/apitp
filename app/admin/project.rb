ActiveAdmin.register Project do
  permit_params :year, :name, :url, :max_upload_size,
                :start_time_date, :start_time_time_hour, :start_time_time_minute,
                :end_time_date, :end_time_time_hour, :end_time_time_minute, :group_ids => [] do
    if Pundit.policy(current_admin_user, Project).chown?
      [:owner_id]
    else
      []
    end
  end

  scope :my_current_projects, default: true do |scope|
    scope.admin_projects(current_admin_user).current
  end

  scope :my_recent_projects do |scope|
    scope.admin_projects(current_admin_user).recent
  end

  scope :all_my_projects do |scope|
    scope.admin_projects(current_admin_user)
  end

  scope :all

  index do
    selectable_column
    id_column
    column :year
    column :name
    column :owner
    column :start_time do |project|
      render_date project.start_time
    end
    column :end_time do |project|
      render_date project.end_time
    end
    column :submitted do |project|
      span project.submitted, class: project_stats_class(project)
    end
    actions
  end

  filter :year
  filter :name
  filter :owner
  filter :start_time
  filter :end_time

  controller do
    def scoped_collection
      Project.stats.includes(:owner)
    end
  end

  form do |f|
    f.object.set_defaults if f.object.new_record?

    f.inputs do
      f.input :year
      f.input :name
      f.input :start_time, as: :just_datetime_picker
      f.input :end_time, as: :just_datetime_picker
      f.input :url
      f.input :max_upload_size
      if Pundit.policy(current_admin_user, Project).chown?
        f.input :owner, include_blank: false, collection: AdminUser.all.map { |user| [ user.name_email, user.id ] }
      end
      f.input :groups, as: :check_boxes,
              collection: Group.where(year: f.object.year).map { |group| [group.display_name, group.id] }
    end
    f.actions
  end

  show do
    attributes_table do
      row :display_name
      row :start_time do |project|
        render_date(project.start_time)
      end
      row :end_time do |project|
        render_date(project.end_time)
      end
      row :url
      row :max_upload_size do |project|
        number_to_human_size(project.max_upload_size)
      end
      row :owner do |project|
        link_to project.owner.name_email, admin_admin_user_path(project.owner)
      end
      row :created_at
      row :updated_at
    end

    panel I18n.t('active_admin.project.show.submission_status') do
      table_for project.user_submissions do
        column :name do |user_submission|
          link_to user_submission.username,
                  admin_user_path(id: user_submission.user_id)
        end
        column :email do |user_submission|
          link_to user_submission.email,
                  "mailto:#{user_submission.email}"
        end
        column I18n.t('activerecord.attributes.submission.created_at') do |user_submission|
          submission = user_submission.submission

          if submission.nil?
            span t('active_admin.project.show.submission_missing'), class: 'submission-missing'
          else

            time_diff = submission.created_at - project.end_time
            link_to render_date(submission.created_at, project.end_time, "due date"),
                    submission.file.url, class: time_diff > 0 ? 'submission-late' : 'submission-ok'
          end
        end
        column I18n.t('activerecord.attributes.submission.size') do |user_submission|
          if user_submission.submission
            number_to_human_size(user_submission.submission.file.size)
          end
        end
        column do |user_submission|
          unless (submission = user_submission.submission).nil?
            if Pundit.policy(current_admin_user, submission).destroy?
              link_to I18n.t('active_admin.delete'),
                      admin_submission_path(submission),
                      method: :delete,
                      data: { confirm: "Delete submission from #{user_submission.username} for #{project.name}?" }
            end
          end
        end
      end
    end
  end

  sidebar I18n.t('active_admin.project.show.assignments'), only: :show do
    table_for project.groups do
      column t('activerecord.attributes.group.display_name') do |group|
        link_to group.display_name, admin_group_path(group)
      end
    end
  end

end
