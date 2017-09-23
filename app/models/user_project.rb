class UserProject < Project
  self.table_name = :user_projects

  belongs_to :user
  belongs_to :submission

  scope :of_user, -> (user) {
    where(user: user).where('start_time <= ?', DateTime.now).includes(:submission)
  }
end
