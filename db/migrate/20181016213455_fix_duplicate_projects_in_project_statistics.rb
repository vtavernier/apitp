class FixDuplicateProjectsInProjectStatistics < ActiveRecord::Migration[5.1]
  include ProjectStatistics

  def up
    recreate_project_statistics_view(5)
  end

  def down
    recreate_project_statistics_view(4)
  end
end
