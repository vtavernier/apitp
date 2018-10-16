class AddSingleTeamUsersToProjectStatisticsView < ActiveRecord::Migration[5.1]
  include ProjectStatistics

  def up
    recreate_project_statistics_view(3)
  end

  def down
    recreate_project_statistics_view(2)
  end
end
