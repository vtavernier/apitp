class UserProject < Project
  self.table_name = :user_projects

  belongs_to :user
  belongs_to :submission

  default_scope -> {
    order(:end_time)
  }

  scope :of_user, -> (user) {
    where(user: user).includes(:submission)
  }
end
