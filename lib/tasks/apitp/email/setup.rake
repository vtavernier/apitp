namespace :apitp do
  namespace :email do
    desc "Setups a recurring task for processing e-mails"
    task :setup => :environment do
      ActiveRecord::Base.transaction do
        # Delete existing jobs for ProcessPendingEmailsJob
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM que_jobs
          WHERE args #>> '{0,job_class}' = 'ProcessPendingEmailsJob';
        SQL

        # Enqueue a job to execute when this task completes
        duration = Rails.env.development? ? 5.seconds : 1.minute
        ProcessPendingEmailsJob.perform_later(reschedule_interval: duration.iso8601)
      end
    end
  end
end