class AddCrossGroupToTeam < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :cross_group, :boolean
  end
end
