class DeleteSubmissionsWithNullFile < ActiveRecord::Migration[5.1]
  def up
    Submission.where(file: nil).delete_all
  end
end
