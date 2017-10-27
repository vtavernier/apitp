class EnsureDistinctProjectStatistics < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW project_statistics AS
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
  end

  def down
    execute "DROP VIEW project_statistics"
  end
end
