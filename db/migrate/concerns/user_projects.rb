module UserProjects
  extend ActiveSupport::Concern

  def recreate_user_projects_view(version)
    drop_user_projects_view
    create_user_projects_view(version)
  end

  def create_user_projects_view(version)
    if version == 1
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
    elsif version == 2
      execute <<-SQL
        CREATE VIEW user_projects AS
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
    elsif version == 3
      execute <<-SQL
        CREATE VIEW user_projects AS
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
            user_submissions.team_id,
            projects.submission_details
          FROM projects
            INNER JOIN user_submissions ON projects.id = user_submissions.project_id
      SQL
    else
      raise "Invalid user_projects_view version: #{version}"
    end
  end

  def drop_user_projects_view
    execute "DROP VIEW IF EXISTS user_projects"
  end
end
