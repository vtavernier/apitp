class AddUniqueToTeamSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_index :submissions, [:project_id, :team_id], unique: true
  end
end
