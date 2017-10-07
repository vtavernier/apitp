class ProjectMailer < ApplicationMailer
  add_template_helper SubmissionsHelper

  def start(project, user, recipient)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.start.subject', name: @project.display_name),
         to: recipient)
  end

  def reminder(project, user, recipient)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.reminder.subject', name: @project.display_name),
         to: recipient)
  end

  def ended(project, user, recipient)
    @project = project
    @user = user
    mail(subject: I18n.t('project_mailer.ended.subject', name: @project.display_name),
         to: recipient)
  end

  def submitted(submission)
    @project = submission.project
    @submission = submission
    @user = submission.user

    recipient = if @user.email =~ /@example\.com$/
                  @project.owner.email
                else
                  @user.email
                end

    mail(subject: I18n.t('project_mailer.submitted.subject', name: @project.display_name),
         to: recipient)
  end
end
