class Assignment < ApplicationRecord
  belongs_to :group
  belongs_to :project

  validates :group, presence: true
  validates :project, presence: true,
            uniqueness: { scope: :group }
end
