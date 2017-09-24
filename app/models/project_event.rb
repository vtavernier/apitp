class ProjectEvent < ApplicationRecord
  def self.earliest
    self.limit(1).pluck(:next_event).first
  end

  scope :project, -> (project) {
    where(id: project.id)
  }
end
