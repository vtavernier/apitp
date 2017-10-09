ActiveAdmin.register Team do
  permit_params :group_id, :group_membership_ids => []

  index do
    selectable_column
    id_column
    column :group do |team|
      link_to team.group.name, admin_group_path(team.group), title: team.group.display_name
    end
    column :members do |team|
      team.users.map { |user| link_to(user.name, admin_user_path(user)) }
                .join(' | ')
                .html_safe
    end
    actions
  end

  filter :group

  form do |f|
    f.inputs do
      f.input :group, include_blank: false
      f.input :group_membership_ids, as: :check_boxes,
              collection: GroupMembership
                              .joins('LEFT OUTER JOIN team_memberships ON team_memberships.group_membership_id = group_memberships.id')
                              .where(f.object.new_record? ? 'team_memberships.id IS NULL' : '')
                              .includes(:user)
                              .sort_by { |gm| gm.user.name_email }
                              .map { |gm| [gm.user.name_email, gm.id, {:'data-group-id' => gm.group_id}] }
    end
    f.actions
  end

  show do
    attributes_table do
      row :group
    end

    panel I18n.t('active_admin.team.show.members') do
      table_for team.users.ordered do
        column :name do |user|
          link_to user.name, admin_user_path(user)
        end
        column :email do |user|
          link_to user.email, "mailto:#{user.email}"
        end
      end
    end
  end
end