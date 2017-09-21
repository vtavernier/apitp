class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.integer :year
      t.string :name
      t.references :admin_user, foreign_key: true

      t.timestamps
    end

     add_index :groups, [:year, :name], unique: true
  end
end
