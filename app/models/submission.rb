class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user, presence: true
  validates :project, presence: true,
            uniqueness: { scope: :user,
                          message: t('submission.unique.error') }

  mount_uploader :file, SubmissionUploader

  validate :file_size

  def file_size
    unless file.file.nil?
      if file.file.size > project.max_upload_size
        errors.add(:file, t('submission.size.error',
                            size: ApplicationController.helpers.number_to_human_size(file.file.size - project.max_upload_size)))
      end
    end
  end
end
