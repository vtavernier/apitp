class CreateProjectEventsView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW project_events AS
        SELECT *
        FROM
          (SELECT
             id,
             LEAST(CASE WHEN start_time < current_timestamp
               THEN NULL
                   ELSE start_time END,
                   CASE WHEN reminder_time < current_timestamp
                     THEN NULL
                   ELSE reminder_time END,
                   CASE WHEN end_time < current_timestamp
                     THEN NULL
                   ELSE end_time END) AS next_event
           FROM project_times) AS events
        WHERE next_event IS NOT NULL
        ORDER BY next_event
    SQL
  end

  def down
    execute "DROP VIEW project_events"
  end
end
