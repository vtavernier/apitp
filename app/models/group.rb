class Group < ApplicationRecord
  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: :year }
  validates :admin, presence: true

  belongs_to :admin, foreign_key: :admin_user_id, class_name: AdminUser

  has_many :assignments
  has_many :projects, through: :assignments

  has_many :group_memberships
  has_many :users, through: :group_memberships
end
