class AdminUser < ApplicationRecord
  include NameEmailConcern

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  validates :name, presence: true, uniqueness: true

  has_many :projects, foreign_key: 'owner_id'

  scope :super_admins, -> { where(super_admin: true) }

  def admin?
    true
  end
end
