class SubmissionsController < ApplicationController
  include DateHelper
  before_action :authenticate_user!

  def create
    submission = Submission.new(submission_params)
    submission.user = current_user

    if submission.save
      # Send e-mail about submitted file
      ProjectMailer.submitted(submission).deliver

      redirect_to project_path(submission.project),
                  notice: "The file has been submitted at #{render_date(submission.created_at, submission.project.end_time, "due time")}."
    else
      redirect_to project_path(submission.project),
                  alert: "Error while uploading the file: #{submission.errors.first[1]}"
    end
  end

private
  def submission_params
    params.require(:submission).permit(:project_id, :file)
  end
end
