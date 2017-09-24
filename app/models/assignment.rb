class Assignment < ApplicationRecord
  belongs_to :group
  belongs_to :project

  validates :group, presence: true
  validates :project, presence: true,
            uniqueness: { scope: :group }

  scope :resend_start, -> {
    joins('INNER JOIN project_times ON assignments.project_id = project_times.id')
      .where('assignments.sent_start_email < project_times.start_time')
  }

  scope :resend_reminder, -> {
    joins('INNER JOIN project_times ON assignments.project_id = project_times.id')
        .where('assignments.sent_reminder_email < project_times.reminder_time')
  }

  scope :resend_ended, -> {
    joins('INNER JOIN project_times ON assignments.project_id = project_times.id')
        .where('assignments.sent_ended_email < project_times.end_time')
  }
end
