class CreateProjectUsersView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW project_users AS
        SELECT DISTINCT
          users.id AS user_id,
          assignments.project_id AS project_id
        FROM users
          INNER JOIN group_memberships ON group_memberships.user_id = users.id
          INNER JOIN assignments ON assignments.group_id = group_memberships.group_id
    SQL
  end

  def down
    execute "DROP VIEW project_users"
  end
end
