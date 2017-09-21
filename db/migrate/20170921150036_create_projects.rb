class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.integer :year
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.string :url
      t.integer :max_upload_size

      t.timestamps
    end
  end
end
