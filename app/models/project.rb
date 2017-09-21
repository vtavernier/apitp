class Project < ApplicationRecord
  include DisplayNameConcern

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }

  validates :start_time, presence: true
  validates :end_time, presence: true

  validates_datetime :end_time, after: :start_time

  validates :max_upload_size, presence: true,
            numericality: { greater_than: 0 }

  has_many :assignments
  has_many :groups, through: :assignments

  has_many :submissions

  def set_defaults
    self.start_time = Date.today.to_datetime
    self.end_time = start_time + 1.week
    self.year = DateHelper.school_year(self.start_time)
    self.max_upload_size = 1 * 1024 * 1024 # 1MB
  end
end
