class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.references :group, foreign_key: true
    end
  end
end
