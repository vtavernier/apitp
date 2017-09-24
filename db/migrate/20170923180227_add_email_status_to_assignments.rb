class AddEmailStatusToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :sent_start_email, :datetime
    add_column :assignments, :sent_reminder_email, :datetime
    add_column :assignments, :sent_ended_email, :datetime
  end
end
