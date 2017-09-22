class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  validates :name, presence: true

  has_many :group_memberships, dependent: :delete_all
  has_many :groups, through: :group_memberships

  has_many :submissions, dependent: :destroy

  def name_email
    "#{name} <#{email}>"
  end
end
