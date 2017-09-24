class AddOwnerToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :owner_id, :integer
    add_foreign_key :projects, :admin_users, column: :owner_id

    reversible do |dir|
      dir.up do
        if (admin = AdminUser.super_admins.first)
          Project.where(owner_id: nil).update_all(owner_id: admin.id)
        end
      end
    end
  end
end
