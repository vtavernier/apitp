class AdminUser < ApplicationRecord
  include NameEmailConcern

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

  validates :name, presence: true, uniqueness: true
end
