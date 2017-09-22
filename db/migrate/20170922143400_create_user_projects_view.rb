class CreateUserProjectsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW user_projects AS
        SELECT DISTINCT
          projects.*,
          submissions.id AS submission_id,
          users.id AS user_id
        FROM users
          INNER JOIN group_memberships ON group_memberships.user_id = users.id
          INNER JOIN assignments ON assignments.group_id = group_memberships.group_id
          INNER JOIN projects ON projects.id = assignments.project_id
          LEFT OUTER JOIN submissions ON submissions.project_id = projects.id
                                      AND submissions.user_id = users.id
    SQL
  end

  def down
    execute "DROP VIEW user_projects"
  end
end
