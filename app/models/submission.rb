class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user, presence: true
  validates :project, presence: true,
            uniqueness: { scope: :user,
                          message: 'You can only upload one file per project.' }

  mount_uploader :file, SubmissionUploader
end
