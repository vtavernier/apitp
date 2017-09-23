class UserProject < Project
  self.table_name = :user_projects

  belongs_to :user
  belongs_to :submission

  scope :of_user, -> (user) {
    where(user: user).includes(:submission)
  }
end
