class AddTeamToUserProjectsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW user_projects AS
        SELECT
          projects.id,
          projects.year,
          projects.name,
          projects.start_time,
          projects.end_time,
          projects.url,
          projects.max_upload_size,
          projects.created_at,
          projects.updated_at,
          user_submissions.submission_id,
          user_submissions.user_id,
          projects.owner_id,
          user_submissions.team_id
        FROM projects
          INNER JOIN user_submissions ON projects.id = user_submissions.project_id
    SQL
  end

  def down
    execute "DROP VIEW user_projects"
  end
end
