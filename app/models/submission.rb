class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user, presence: true
  validates :project, presence: true,
            uniqueness: { scope: :user,
                          message: 'You can only upload one file per project.' }

  mount_uploader :file, SubmissionUploader

  validate :file_size

  def file_size
    unless file.file.nil?
      if file.file.size > project.max_upload_size
        errors.add(:file, "The chosen file is #{ApplicationController.helpers.number_to_human_size(file.file.size - project.max_upload_size)} too big for this project.")
      end
    end
  end
end
