class PendingEmail < ApplicationRecord
  self.abstract_class = true

  belongs_to :project
  belongs_to :user

  scope :complete, -> {
    includes(:project, :user)
  }
end
