class AdminMailer < ApplicationMailer
  def import_failed(admin_user, file_name, exception)
    @user = admin_user
    @file_name = file_name
    @exception = exception
    mail(subject: I18n.t('admin_mailer.import_failed.subject'),
         to: admin_user.email, gpg: gpg_options)
  end

  def import_succeeded(admin_user, file_name, created_users, created_groups)
    @user = admin_user
    @file_name = file_name
    @created_users = created_users
    @created_groups = created_groups
    mail(subject: I18n.t('admin_mailer.import_succeeded.subject'),
         to: admin_user.email, gpg: gpg_options)
  end

  def move_submissions(admin_user, messages)
    @user = admin_user
    @messages = messages
    mail(subject: I18n.t('admin_mailer.move_submissions.subject'),
         to: admin_user.email, gpg: gpg_options)
  end
end
