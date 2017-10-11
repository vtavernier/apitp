class AddGroupToUserSubmissionsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW user_submissions AS
        SELECT
          a.user_id,
          a.username,
          a.email,
          a.project_id,
          submissions.id       AS submission_id,
          a.team_id,
          submissions.team_id  AS submission_team_id,
          a.group_id
        FROM (SELECT
                users.id                 AS user_id,
                users.name               AS username,
                users.email              AS email,
                assignments.project_id   AS project_id,
                team_memberships.team_id AS team_id,
                assignments.group_id     AS group_id
              FROM users
                INNER JOIN group_memberships ON group_memberships.user_id = users.id
                INNER JOIN assignments ON assignments.group_id = group_memberships.group_id
                LEFT OUTER JOIN submissions ON submissions.project_id = assignments.project_id
                                               AND submissions.user_id = users.id
                LEFT OUTER JOIN team_memberships ON team_memberships.group_membership_id = group_memberships.id) a
          LEFT OUTER JOIN submissions ON (submissions.user_id = a.user_id
                                          OR (submissions.team_id IS NOT NULL AND submissions.team_id = a.team_id))
                                         AND submissions.project_id = a.project_id
        ORDER BY a.username, a.email
    SQL
  end

  def down
    execute "DROP VIEW user_submissions"
  end
end
