class ProjectMailer < ApplicationMailer
  add_template_helper SubmissionsHelper

  def start(project, user)
    @project = project
    @user = user
    mail(subject: "[APITP] Welcome to #{@project.display_name}",
         to: user.email)
  end

  def submitted(submission)
    @project = submission.project
    @submission = submission
    @user = submission.user
    mail(subhect: "[APITP] File submitted for #{@project.display_name}",
         to: @user.email)
  end
end
