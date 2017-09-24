class ProjectMailer < ApplicationMailer
  add_template_helper SubmissionsHelper

  def start(project, user)
    @project = project
    @user = user
    mail(subject: "[APITP] Welcome to #{@project.display_name}",
         to: user.email)
  end

  def reminder(project, user)
    @project = project
    @user = user
    mail(subject: "[APITP] #{@project.display_name} is due soon",
         to: user.email)
  end

  def ended(project, user)
    @project = project
    @user = user
    mail(subject: "[APITP] #{@project.display_name} is past due date",
         to: user.email)
  end

  def submitted(submission)
    @project = submission.project
    @submission = submission
    @user = submission.user
    mail(subject: "[APITP] File submitted for #{@project.display_name}",
         to: @user.email)
  end
end
