module ProjectHelper
  def project_stats_class(project)
    if project.submission_count == project.user_count
      'project-stats-complete'
    else
      if project.end_time < DateTime.now
        'project-stats-missing-late'
      else
        'project-stats-missing'
      end
    end
  end
end
