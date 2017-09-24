class CreateProjectTimesView < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW project_times AS
        SELECT projects.id,
               projects.start_time,
               projects.end_time,
               DATE_TRUNC('hour',
                  projects.start_time + (projects.end_time - projects.start_time) * 6/7) AS reminder_time
        FROM projects
    SQL
  end

  def down
    execute "DROP VIEW project_times"
  end
end
