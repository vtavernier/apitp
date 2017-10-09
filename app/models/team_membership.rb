class TeamMembership < ApplicationRecord
  belongs_to :team
  belongs_to :group_membership

  has_one :user, through: :group_membership

  validates :team, presence: true
  validates :group_membership, presence: true
  validates :group_membership, uniqueness: true
end
