namespace :apitp do
  namespace :team do
    desc "Moves the submissions to the respective teams"
    task :move_submissions => :environment do
      ActiveRecord::Base.transaction do
        UserSubmissions.where(submission_team_id: nil).where.not(submission_id: nil, team_id: nil).each do |user_submission|
          if UserSubmissions.where('submission_id != ?', user_submission.submission_id)
                            .exists?(project_id: user_submission.project_id,
                                     team_id: user_submission.team_id,
                                     submission_team_id: user_submission.team_id)
            puts "#{user_submission.submission_id} (#{user_submission.user.name_email} on #{user_submission.project_id}) not updated because it would conflict with another submission for this team"
          else
            submission = user_submission.submission
            submission.team_id = user_submission.team_id
            if submission.valid?
              submission.save
              puts "Assigned #{submission.id} from #{submission.user.name_email} to its team"
            else
              puts "Submission #{submission.id} from #{submission.user.name_email} could not be assigned to a team"
            end
          end
        end
      end
    end
  end
end