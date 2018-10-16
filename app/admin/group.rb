ActiveAdmin.register Group do
  permit_params :year, :name, :admin_user_id, :user_ids => []

  scope :administered, default: true do |scope|
    scope.administered(current_admin_user)
  end
  scope :current
  scope :all

  index do
    selectable_column
    id_column
    column :year
    column :name
    column :admin
    actions
  end

  filter :year
  filter :name
  filter :admin

  form do |f|
    f.inputs do
      f.input :year
      f.input :name
      f.input :admin, include_blank: false,
              collection: AdminUser.all.map { |user| [ user.name_email, user.id ] }
      f.input :users, as: :check_boxes,
              collection: User.all.map { |user| [user.name_email, user.id] }
    end
    f.actions
  end

  show do
    attributes_table do
      row :display_name
      row :admin
      row :created_at
      row :updated_at
      row I18n.t('active_admin.group.show.mail_everyone') do
        link_to I18n.t('active_admin.group.show.send_mail'), "mailto:#{group.users.collect(&:email).join(";")}"
      end
    end

    columns do
      column do
        panel I18n.t('active_admin.group.show.members') do
          table_for group.users.ordered do
            column :name do |user|
              link_to user.name, admin_user_path(user)
            end
            column :email do |user|
              link_to user.email, "mailto:#{user.email}"
            end
          end
        end
      end

      column do
        panel I18n.t('active_admin.group.show.assignments') do
          table_for group.projects.stats.ordered do
            column :display_name do |project|
              link_to project.display_name, admin_project_path(project)
            end
            column(:start_date) { |project| l project.start_time, format: :long }
            column(:end_date) { |project| l project.end_time, format: :long }
            column :submitted do |project|
              span project.submitted, class: project_stats_class(project)
            end
          end
        end
      end
    end
  end

end
