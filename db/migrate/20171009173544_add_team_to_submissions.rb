class AddTeamToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_reference :submissions, :team, foreign_key: true
  end
end
