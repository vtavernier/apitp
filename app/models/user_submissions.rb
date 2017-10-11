class UserSubmissions < ApplicationRecord
  scope :project, -> (project) {
    where(project: project)
  }

  belongs_to :user
  belongs_to :project
  belongs_to :submission
  belongs_to :team
  belongs_to :submission_team, class_name: 'Team'
  belongs_to :group
end
