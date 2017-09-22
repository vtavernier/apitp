class UserSubmissions < ApplicationRecord
  scope :project, -> (project) {
    where(project: project)
  }

  belongs_to :user
  belongs_to :project
  belongs_to :submission
end
