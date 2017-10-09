class AddTeamToProjectStatisticsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW project_statistics AS
        SELECT
          project_id,
          COUNT(DISTINCT CASE WHEN team_id IS NOT NULL AND submission_team_id IS NULL
            THEN NULL
                         ELSE submission_id END)              AS submission_count,
          COUNT(*) - COUNT(team_id) + COUNT(DISTINCT team_id) AS user_count
        FROM user_submissions
        GROUP BY project_id
    SQL
  end

  def down
    execute "DROP VIEW project_statistics"
  end
end
