class AddSubmissionDetailsToProject < ActiveRecord::Migration[5.1]
  include UserProjects

  def up
    add_column :projects, :submission_details, :text
    recreate_user_projects_view(1)
  end

  def down
    drop_user_projects_view
    remove_column :projects, :submission_details
    create_user_projects_view(1)
  end
end
