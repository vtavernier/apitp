class Project < ApplicationRecord
  include DisplayNameConcern
  include UnicityConcern

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
                            less_than_or_equal_to: Rails.configuration.x.apitp.max_upload_size }

  has_many :assignments, dependent: :delete_all
  has_many :groups, through: :assignments

  has_many :submissions, dependent: :destroy

  validates :owner, presence: true
  belongs_to :owner, class_name: 'AdminUser', foreign_key: 'owner_id', inverse_of: :projects

  scope :started, -> { where('start_time <= ?', DateTime.now) }
  scope :current, -> { where('start_time <= :now AND end_time >= :now', { now: DateTime.now }) }
  scope :ended, -> { where('end_time < ?', DateTime.now) }
  scope :recent, -> { where(<<-SQL, { today: DateTime.now.at_beginning_of_day, in_one_week: (DateTime.now + 1.week).at_beginning_of_day, two_weeks_ago: (DateTime.now - 2.week).at_beginning_of_day })
      (:today <= start_time AND :in_one_week >= start_time) OR
      (:today >= end_time AND :two_weeks_ago <= end_time) OR
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

  scope :user, -> (user) {
    where(user: user).where('start_time <= ?', DateTime.now)
  }

  scope :ordered, -> {
    order(:end_time, :name)
  }

  scope :owned_projects, -> (admin) {
    where(owner: admin)
  }

  scope :admin_projects, -> (admin) {
    joins('INNER JOIN assignments ON projects.id = assignments.project_id')
    .joins('INNER JOIN groups ON assignments.group_id = groups.id')
    .where('owner_id = :id OR admin_user_id = :id', { id: admin.id })
    .distinct
  }

  def submitted
    "#{submission_count}/#{user_count}"
  end

  def assignment_group(user)
    Group.where('id IN (?)', user.group_memberships.select(:group_id))
         .where('id IN (?)', assignments.select(:group_id)).first
  end

  def user_submissions
    UserSubmissions.project(self).includes(:submission).includes(:user)
  end

  def set_defaults(owner)
    self.start_time = DateTime.now.at_beginning_of_day
    self.end_time = start_time + 1.week
    self.year = SchoolDateHelper.school_year(self.start_time)
    # 500kB or max size / 2
    self.max_upload_size = [500 * 1024, Rails.configuration.x.apitp.max_upload_size / 2].min
    self.owner = owner
  end

  def empty?
    return (self.start_time.nil? and
           self.end_time.nil? and
           self.year.nil? and
           self.max_upload_size.nil? and
           self.owner_id.nil?)
  end

  def all_submissions
    submissions_ary = []
    submissions_hash = Hash.new { |hash, key| ary = []; submissions_ary << [ key, ary ]; hash[key] = ary; }

    user_submissions.each do |user_submission|
      if user_submission.team_id.nil?
        # single user, just add to list
        submissions_ary << [ nil, [ user_submission ] ]
      else
        submissions_hash[user_submission.team_id] << user_submission
      end
    end

    submissions_ary
  end

  def to_xls(options = {})
    wb = Spreadsheet::Workbook.new
    sheet = wb.create_worksheet name: name

    current_row = 0
    export_lines do |line|
      sheet.row(current_row).replace line
      current_row += 1
    end

    file_contents = StringIO.new
    wb.write(file_contents)
    return file_contents.string.force_encoding('binary')
  end

  def to_csv(options = {})
    CSV.generate(options) do |csv|
      export_lines do |line|
        csv << line
      end
    end
  end

  before_save :prepare_check_resend
  after_save :check_resend

  validate :project_assignment_uniqueness

  private
    def export_lines
      # Load all submissions
      all_submissions.group_by { |_team_id, us| us.first.group_id }
                     .sort_by { |_group_id, submissions| submissions.map { |_team_id, us| us.first.group.name } }
                     .each do |group_id, submissions|
        # Max count
        max_count = submissions.map { |_team_id, s| s.uniq(&:user_id).length }.max
        filler = max_count.times.collect { "" }
        full_filler = (max_count + 2).times.collect { "" }
        # Group header
        yield([ Group.where(id: group_id).pluck(:name).first ] + full_filler)
        # Column headers
        yield([ I18n.t('activerecord.models.team', count: 1) ] + filler + [ I18n.t('project.export.sent'), I18n.t('project.export.grade') ])
        # Process
        submissions.each do |team_id, us|
          # Get the list of users
          users = us.uniq(&:user_id).collect(&:username)
          if users.length < max_count
            users.concat(Array.new(max_count - users.length, ""))
          end

          # Submission status
          earliest_submission = us.map(&:submission).reject(&:nil?).min_by(&:created_at)
          submission_status = if earliest_submission.nil?
                                ""
                              else
                                if earliest_submission.created_at > end_time
                                  I18n.t('project.export.late')
                                else
                                  I18n.t('project.export.submitted')
                                end
                              end

          yield([ team_id ] + users + [ submission_status, "" ])
        end

        yield([ "" ] + full_filler)
      end
    end

    def prepare_check_resend
      @start_time_changed = start_time_changed?
      @end_time_changed = end_time_changed?
    end

    def check_resend
      if @start_time_changed
        if start_time >= DateTime.now
          # If the project has been moved to a future date, e-mails should be sent
          assignments.resend_start.update_all(sent_start_email: nil)
        end
      end

      if @end_time_changed
        if end_time >= DateTime.now
          # If the project has been moved to a future date, e-mails should be sent again
          assignments.resend_ended.update_all(sent_ended_email: nil)
        end
      end

      if @start_time_changed or @end_time_changed
        if (start_time + (end_time - start_time) * 6/7) >= DateTime.now
          # See above
          assignments.resend_reminder.update_all(sent_reminder_email: nil)
        end
      end
    end
end
