module ProjectStatistics
  extend ActiveSupport::Concern

  def recreate_project_statistics_view(version)
    drop_project_statistics_view
    create_project_statistics_view(version)
  end

  def create_project_statistics_view(version)
    if version == 1
      execute <<-SQL
        CREATE VIEW project_statistics AS
          SELECT project_id,
                 COUNT(submission_id) AS submission_count,
                 COUNT(*) AS user_count
          FROM user_submissions GROUP BY project_id;
      SQL
    elsif version == 2
      execute <<-SQL
        CREATE VIEW project_statistics AS
          SELECT
            project_id,
            COUNT(DISTINCT CASE WHEN team_id IS NOT NULL AND submission_team_id IS NULL
              THEN NULL
                           ELSE submission_id END)              AS submission_count,
            COUNT(*) - COUNT(team_id) + COUNT(DISTINCT team_id) AS user_count
          FROM user_submissions
          GROUP BY project_id;
      SQL
    elsif version == 3
      execute <<-SQL
        CREATE VIEW project_statistics AS
          SELECT
            a.project_id,
            a.submission_count + COALESCE(b.count, 0) AS submission_count,
            a.user_count
          FROM (SELECT
                  project_id,
                  COUNT(DISTINCT CASE WHEN team_id IS NOT NULL AND submission_team_id IS NULL
                    THEN NULL
                                 ELSE submission_id END)              AS submission_count,
                  COUNT(*) - COUNT(team_id) + COUNT(DISTINCT team_id) AS user_count
                FROM user_submissions
                GROUP BY project_id) a
            LEFT OUTER JOIN (SELECT
                               project_id,
                               1 AS count
                             FROM user_submissions
                             WHERE team_id IS NOT NULL AND submission_team_id IS NULL
                             GROUP BY project_id, team_id
                             HAVING COUNT(submission_id) >= COUNT(user_id)) b ON a.project_id = b.project_id;
      SQL
    elsif version == 4
      execute <<-SQL
        CREATE VIEW project_statistics AS
          SELECT DISTINCT
            a.project_id,
            a.submission_count + COALESCE(b.count, 0) AS submission_count,
            a.user_count
          FROM (SELECT
                  project_id,
                  COUNT(DISTINCT CASE WHEN team_id IS NOT NULL AND submission_team_id IS NULL
                    THEN NULL
                                 ELSE submission_id END)              AS submission_count,
                  COUNT(*) - COUNT(team_id) + COUNT(DISTINCT team_id) AS user_count
                FROM user_submissions
                GROUP BY project_id) a
            LEFT OUTER JOIN (SELECT
                               project_id,
                               COUNT(user_submissions.submission_id) AS count
                             FROM user_submissions
                             WHERE team_id IS NOT NULL AND submission_team_id IS NULL
                             GROUP BY project_id, team_id
                             HAVING COUNT(submission_id) >= COUNT(user_id)) b ON a.project_id = b.project_id;
      SQL
    elsif version == 5
      execute <<-SQL
        CREATE VIEW project_statistics AS
          SELECT
            a.project_id,
            MAX(a.submission_count + COALESCE(b.count, 0)) AS submission_count,
            MAX(a.user_count) AS user_count
          FROM (SELECT
                  project_id,
                  COUNT(DISTINCT CASE WHEN team_id IS NOT NULL AND submission_team_id IS NULL
                    THEN NULL
                                 ELSE submission_id END)              AS submission_count,
                  COUNT(*) - COUNT(team_id) + COUNT(DISTINCT team_id) AS user_count
                FROM user_submissions
                GROUP BY project_id) a
            LEFT OUTER JOIN (SELECT
                               project_id,
                               COUNT(user_submissions.submission_id) AS count
                             FROM user_submissions
                             WHERE team_id IS NOT NULL AND submission_team_id IS NULL
                             GROUP BY project_id, team_id
                             HAVING COUNT(submission_id) >= COUNT(user_id)) b ON a.project_id = b.project_id
          GROUP BY a.project_id;
      SQL
    else
      raise "Invalid project_statistics_view version: #{version}"
    end
  end

  def drop_project_statistics_view
    execute "DROP VIEW IF EXISTS project_statistics"
  end
end
