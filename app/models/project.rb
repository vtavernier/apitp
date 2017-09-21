class Project < ApplicationRecord
  include DisplayNameConcern

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }

  validates :start_time, presence: true
  validates :end_time, presence: true

  just_define_datetime_picker :start_time
  just_define_datetime_picker :end_time

  validates_datetime :end_time, after: :start_time

  validates :max_upload_size, presence: true,
            numericality: { greater_than: 0 }

  has_many :assignments, dependent: :delete_all
  has_many :groups, through: :assignments

  has_many :submissions, dependent: :destroy

  scope :current, -> { where('start_time >= ? AND end_time >= ?', Date.today, DateTime.now) }
  scope :ended, -> { where('end_time >= ? AND end_time <= ?', DateTime.now - 1.week, DateTime.now) }

  scope :of_user, -> (user) { joins(:assignments).where('group_id IN (?)', user.group_memberships.select(:group_id)) }

  def user_submission(user)
    submissions.find_by_user_id(user.id)
  end

  def assignment_group(user)
    Group.where('id IN (?)', user.group_memberships.select(:group_id))
         .where('id IN (?)', assignments.select(:group_id)).first
  end

  def user_submissions
    User.joins('LEFT OUTER JOIN submissions ON users.id = submissions.user_id AND submissions.project_id = ' + self.id.to_s)
        .joins(:group_memberships) #'JOIN group_memberships ON group_memberships.user_id = users.id')
        .joins('JOIN assignments ON assignments.group_id = group_memberships.group_id AND assignments.project_id = ' + self.id.to_s)
        .select('users.*, submissions.*')
        .order('users.name')
        .map do |user|
      submission = Submission.instantiate(user.attributes)
      if submission.created_at.nil?
        submission = nil
      end
      [user, submission]
    end
  end

  def set_defaults
    self.start_time = Date.today.to_datetime
    self.end_time = start_time + 1.week
    self.year = DateHelper.school_year(self.start_time)
    self.max_upload_size = 1 * 1024 * 1024 # 1MB
  end
end
