class CreateTeamMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :team_memberships do |t|
      t.references :team, foreign_key: true, dependent: :destroy
      t.references :group_membership
    end

    add_foreign_key :team_memberships, :group_memberships, column: :group_membership_id, unique: true
  end
end
