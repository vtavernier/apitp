class CreateAdministeredUsersProcedure < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE FUNCTION administered_users(target_admin_user_id integer)
        RETURNS SETOF users AS
      $func$
        SELECT DISTINCT users.*
        FROM users
        INNER JOIN group_memberships ON users.id = group_memberships.user_id
        INNER JOIN groups ON group_memberships.group_id = groups.id
        WHERE groups.admin_user_id = target_admin_user_id
      $func$ LANGUAGE sql;
    SQL
  end

  def down
    execute "DROP FUNCTION administered_users(target_admin_user_id integer)"
  end
end
