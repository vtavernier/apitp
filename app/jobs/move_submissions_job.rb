class MoveSubmissionsJob < ApplicationJob
  queue_as :default

  def perform(admin_user)
    messages = []

    begin
      results = Submission.connection.execute <<-SQL
        UPDATE submissions
        SET team_id = t.team_id
        FROM (SELECT
                min(submission_id) AS submission_id,
                team_id
              FROM user_submissions
              WHERE submission_team_id IS NULL
                    AND team_id IS NOT NULL
                    AND submission_id IS NOT NULL
              GROUP BY project_id, team_id
              HAVING COUNT(DISTINCT user_id) = 1) t
        WHERE submissions.id = t.submission_id
        RETURNING submissions.id, t.team_id;
      SQL

      results.each do |result|
        messages << "Assigned #{result['id']} to #{result['team_id']}"
      end
    rescue StandardError => e
      messages << "#{e}"
    end

    if admin_user.nil?
      messages.each(&:puts)
    else
      AdminMailer.move_submissions(admin_user, messages).deliver_later
    end
  end
end
