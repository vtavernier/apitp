module SubmissionsHelper
  def submission_late?(project, submission)
    submission_date = submission ? submission.created_at : DateTime.now
    return submission_date > project.end_time
  end

  def submission_status(project, submission)
    submission_late = submission_late?(project, submission)

    if submission then
      if submission_late then
        'warning'
      else
        'success'
      end
    else
      if submission_late then
        'danger'
      else
        'info'
      end
    end
  end
end
