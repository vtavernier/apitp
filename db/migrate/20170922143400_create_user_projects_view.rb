class CreateUserProjectsView < ActiveRecord::Migration[5.1]
  include UserProjects

  def up
    create_user_projects_view(1)
  end

  def down
    drop_user_projects_view
  end
end
