class Project < ApplicationRecord
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
end
