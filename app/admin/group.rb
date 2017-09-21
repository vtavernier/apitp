ActiveAdmin.register Group do
  permit_params :year, :name, :admin, :user_ids => []

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
      f.input :admin, include_blank: false
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
    end

    panel I18n.t('active_admin.group.show.members') do
      table_for group.users do
        column :name
        column :email
        column do |user|
          link_to I18n.t('active_admin.view'), admin_user_path(user)
        end
      end
    end
  end

end
