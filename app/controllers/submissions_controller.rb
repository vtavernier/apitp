class SubmissionsController < ApplicationController
  include DateHelper
  before_action :authenticate_user!, only: [ :create ]

  def create
    submission = Submission.new(file: params[:submission][:file])
    submission.project = UserProject.of_user(current_user).find(params[:submission][:project_id])
    submission.user = current_user
    submission.team = submission.project.team

    # Ensure access
    authorize submission

    if submission.save
      # Send e-mail about submitted file
      ProjectMailer.submitted(submission).deliver_later

      redirect_to project_path(submission.project),
                  notice: I18n.t('submissions.create.success',
                                 date: render_date(submission.created_at,
                                                   submission.project.end_time,
                                                   I18n.t('project.due_date_distance')))
    else
      # Delete file after failure
      submission.file.file.delete unless submission.file.file.nil?

      redirect_to project_path(submission.project),
                  alert: I18n.t('submissions.create.error', error: submission.errors.first[1])
    end
  end

  def show
    submission_user = if admin_user_signed_in?
                        current_admin_user
                      else
                        current_user
                      end

    if submission_user.nil?
      # Delegate to Devise when no user
      authenticate_user!
    end

    # Find the submission
    submission = Submission.find(params[:id])

    # Authorize
    Pundit.authorize(submission_user, submission, :show?)

    # Render the file
    full_name = if admin_user_signed_in?
                  extension_match = submission.file.path.match /(\.[a-zA-Z0-9]{1,5})+$/
                  extension  = if extension_match
                                 extension_match.to_s
                               else
                                 File.extname(submission.file.path)
                               end

                  submission_users = if submission.team_id.nil?
                                       [ submission.user.name ]
                                     else
                                       submission.team.users.order(:name).pluck(:name)
                                     end

                  file_name = "#{submission.project.name}_#{submission_users.join('_')}_#{submission.id}"
                  file_name.parameterize + extension
                else
                  File.basename(submission.file.path)
                end

    send_file submission.file.path, filename: full_name
  end
end
