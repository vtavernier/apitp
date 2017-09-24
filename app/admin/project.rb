ActiveAdmin.register Project do
  permit_params :year, :name, :url, :max_upload_size,
                :start_time_date, :start_time_time_hour, :start_time_time_minute,
                :end_time_date, :end_time_time_hour, :end_time_time_minute,
                :group_ids => []

  scope :recent, default: true
  scope :current
  scope :ended
  scope :all

  index do
    selectable_column
    id_column
    column :year
    column :name
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
  filter :start_time
  filter :end_time

  controller do
    def scoped_collection
      Project.stats
    end

    after_create do |project|
      if project.persisted?
        # Notify all users that have been added to this project
        ProjectUser.users(project).includes(:user).each do |project_user|
          ProjectMailer.start(project, project_user.user).deliver_later
        end
      end
    end

    def update
      # Get the list of existing users for this project that we should not notify
      @existing_users = ProjectUser.users(resource).pluck(:user_id).to_set
      super
    end

    after_update do |project|
      unless project.changed?
        ProjectUser.users(project).includes(:user).each do |project_user|
          # Only notify users who have been added to this project
          unless @existing_users.include? project_user.user_id
            ProjectMailer.start(project, project_user.user).deliver_later
          end
        end
      end
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
      row :created_at
      row :updated_at
    end

    panel I18n.t('active_admin.project.show.submission_status') do
      table_for project.user_submissions do
        column :name do |user_submission|
          user_submission.username
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
            link_to I18n.t('active_admin.delete'),
                    admin_submission_path(submission),
                    method: :delete,
                    data: { confirm: "Delete submission from #{user_submission.username} for #{project.name}?" }
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
