class ProjectUser < ApplicationRecord
  belongs_to :project
  belongs_to :user

  scope :users, -> (project) {
    where(project: project)
  }
end
