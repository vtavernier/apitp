class ResetPasswordJob < ApplicationJob
  queue_as :default

  def perform(ids)
    User.find(ids).each do |user|
      user.send_reset_password_instructions
    end
  end
end