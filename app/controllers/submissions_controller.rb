class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def create
    submission = Submission.new(submission_params)

    if submission.project.max_upload_size < submission.file.size
      redirect_to project_path(submission.project),
                  alert: "The chosen file is too big: #{submission.file.size} bytes."
    else
      submission.user = current_user

      if submission.save
        redirect_to project_path(submission.project),
                    notice: "The file has been submitted at #{render_date(submission.created_at, submission.project.end_time, "due time")}."
      else
        redirect_to project_path(submission.project),
                    alert: "Error while uploading the file: #{submission.errors.full_messages.first}"
      end
    end
  end

private
  def submission_params
    params.require(:submission).permit(:project_id, :file)
  end
end
