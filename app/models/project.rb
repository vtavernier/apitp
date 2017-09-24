class Project < ApplicationRecord
  include DisplayNameConcern

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }

  validates :start_time, presence: true
  validates :end_time, presence: true

  just_define_datetime_picker :start_time
  just_define_datetime_picker :end_time

  validates_datetime :end_time, after: :start_time

  validates :url, url: { allow_blank: true }

  validates :max_upload_size, presence: true,
            numericality: { greater_than: 0,
                            less_than_or_equal_to: 1 * 1024 * 1024 }

  has_many :assignments, dependent: :delete_all
  has_many :groups, through: :assignments

  has_many :submissions, dependent: :destroy

  scope :current, -> { where('start_time <= ? AND end_time >= ?', Date.today, DateTime.now) }
  scope :ended, -> { where('end_time < ?', DateTime.now) }
  scope :ended_recently, -> { where('end_time >= ? AND end_time <= ?', DateTime.now - 1.week, DateTime.now) }
  scope :recent, -> { where(<<-SQL, { today: Date.today, in_one_week: Date.today + 1.week, one_week_ago: Date.today - 1.week })
      (:today <= start_time AND :in_one_week >= start_time) OR
      (:today >= end_time AND :one_week_ago <= end_time) OR
      (:today >= start_time AND :today <= end_time)
    SQL
  }

  scope :stats, -> { select(<<-SQL)
      projects.*,
      COALESCE(submission_count, 0) AS submission_count,
      COALESCE(user_count, 0) AS user_count
    SQL
    .joins(<<-SQL)
      LEFT OUTER JOIN project_statistics ON project_statistics.project_id = projects.id
    SQL
  }

  scope :ordered, -> { order(:end_time, :name) }

  def submitted
    "#{submission_count}/#{user_count}"
  end

  def assignment_group(user)
    Group.where('id IN (?)', user.group_memberships.select(:group_id))
         .where('id IN (?)', assignments.select(:group_id)).first
  end

  def user_submissions
    UserSubmissions.project(self).includes(:submission)
  end

  def set_defaults
    self.start_time = DateTime.now.at_beginning_of_day
    self.end_time = start_time + 1.week
    self.year = SchoolDateHelper.school_year(self.start_time)
    self.max_upload_size = 500 * 1024 # 500kB
  end

  after_save :check_resend

  private
    def check_resend
      assignments.resend_start.update_all(sent_start_email: nil)
      assignments.resend_reminder.update_all(sent_reminder_email: nil)
      assignments.resend_ended.update_all(sent_ended_email: nil)
    end
end
