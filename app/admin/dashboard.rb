ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard.title") }

  content title: proc{ I18n.t("active_admin.dashboard.title") } do
    columns do
      column do
        def project_table(projects)
          table_for projects.stats.ordered do
            column :display_name do |project|
              link_to project.display_name, admin_project_path(project)
            end
            column :end_time do |project|
              render_date project.end_time
            end
            column :submitted do |project|
              span project.submitted, class: project_stats_class(project)
            end
          end
        end

        panel I18n.t('active_admin.dashboard.current_projects') do
          project_table(Project.current)
        end

        panel I18n.t('active_admin.dashboard.ended_recently_projects') do
          project_table(Project.ended_recently)
        end
      end
      column do
        panel I18n.t('active_admin.dashboard.admin_groups') do
          table_for Group.current.find_by_admin_user_id(current_admin_user.id) do
            column :display_name do |group|
              link_to group.display_name, admin_group_path(group)
            end
          end
        end
      end
    end
  end # content
end
