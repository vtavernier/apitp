class CreateSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :submissions do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true
      t.string :file

      t.timestamps
    end

    add_index :submissions, [:user_id, :project_id], unique: true
  end
end
