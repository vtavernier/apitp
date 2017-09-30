class ProjectMailer < ApplicationMailer
  add_template_helper SubmissionsHelper

  def start(project, user)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.start.subject', name: @project.display_name),
         to: user.email)
  end

  def reminder(project, user)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.reminder.subject', name: @project.display_name),
         to: user.email)
  end

  def ended(project, user)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.ended.subject', name: @project.display_name),
         to: user.email)
  end

  def submitted(submission)
    @project = submission.project
    @submission = submission
    @user = submission.user
    mail(subject: I18n.t('project_mailer.submitted.subject', name: @project.display_name),
         to: @user.email)
  end
end
