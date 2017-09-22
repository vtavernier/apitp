class CreateUserSubmissionsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW user_submissions AS
        SELECT DISTINCT
               users.id AS user_id,
               users.name AS username,
               users.email AS email,
               assignments.project_id AS project_id,
               submissions.id AS submission_id
        FROM users
          INNER JOIN group_memberships ON group_memberships.user_id = users.id
          INNER JOIN assignments ON assignments.group_id = group_memberships.group_id
          LEFT OUTER JOIN submissions ON submissions.project_id = assignments.project_id
                                         AND submissions.user_id = users.id
        ORDER BY users.name, users.email
    SQL
  end

  def down
    execute "DROP VIEW user_submissions"
  end
end
