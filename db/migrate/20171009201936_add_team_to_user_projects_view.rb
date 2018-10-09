class AddTeamToUserProjectsView < ActiveRecord::Migration[5.1]
  include UserProjects

  def up
    recreate_user_projects_view(2)
  end

  def down
    recreate_user_projects_view(1)
  end
end
