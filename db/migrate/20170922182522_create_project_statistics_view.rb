class CreateProjectStatisticsView < ActiveRecord::Migration[5.1]
  include ProjectStatistics

  def up
    recreate_project_statistics_view(1)
  end

  def down
    drop_project_statistics_view
  end
end
