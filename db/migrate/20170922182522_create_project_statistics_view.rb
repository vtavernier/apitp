class CreateProjectStatisticsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW project_statistics AS
        SELECT project_id,
               COUNT(submission_id) AS submission_count,
               COUNT(*) AS user_count
        FROM user_submissions GROUP BY project_id;
    SQL
  end

  def down
    execute "DROP VIEW project_statistics"
  end
end
