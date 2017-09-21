ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation, :group_ids => []

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :groups, as: :check_boxes,
              collection: Group.all.map { |group| [group.display_name, group.id] }
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :email do |user|
        link_to user.email, "mailto:#{user.email}"
      end
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end

  sidebar I18n.t('active_admin.user.show.groups'), only: :show do
    table_for user.groups do
      column t('activerecord.attributes.group.display_name') do |group|
        link_to group.display_name, admin_group_path(group)
      end
    end
  end

end
