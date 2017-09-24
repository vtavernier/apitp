class AdminMailer < ApplicationMailer
  def import_failed(admin_user, file_name, exception)
    @user = admin_user
    @file_name = file_name
    @exception = exception
    mail(subject: '[APITP] Import failed',
         to: admin_user.email)
  end

  def import_succeeded(admin_user, file_name, created_users, created_groups)
    @user = admin_user
    @file_name = file_name
    @created_users = created_users
    @created_groups = created_groups
    mail(subject: '[APITP] Import succeeded',
         to: admin_user.email)
  end
end
