module ProjectHelper
  def project_stats_class(project)
    if project.submission_count == project.user_count
      'badge badge-success'
    else
      if project.end_time < DateTime.now
        'badge badge-warning'
      else
        'badge badge-danger'
      end
    end
  end
end
