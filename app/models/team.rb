class Team < ApplicationRecord
  belongs_to :group

  has_many :team_memberships, dependent: :destroy
  has_many :group_memberships, through: :team_memberships
  has_many :users, through: :group_memberships
  has_many :submissions, dependent: :nullify

  validates :team_memberships, length: { minimum: 1 }

  validates :group, presence: true

  validate :ensure_same_group, unless: :cross_group?

  private
    def ensure_same_group
      if Set.new(group_memberships.pluck(:group_id)).length > 1
        errors.add(:group, I18n.t('team.must_be_on_same_group'))
      end
    end
end

