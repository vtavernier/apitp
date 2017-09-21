class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.references :group, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end

    add_index :assignments, [:group_id, :project_id], unique: true
  end
end
