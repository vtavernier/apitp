class User < ApplicationRecord
  include NameEmailConcern

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  validates :name, presence: true

  has_many :group_memberships, dependent: :delete_all
  has_many :groups, through: :group_memberships

  has_many :submissions, dependent: :destroy

  scope :ordered, -> { order(:name, :email) }
  scope :admin, -> (admin) { from("administered_users(#{sanitize_sql(admin.id)}) AS #{self.table_name}") }

  def admin?
    false
  end

  def super_admin?
    false
  end
end
