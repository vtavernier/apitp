class ProcessPendingEmailsJob < ApplicationJob
  queue_as :user_email

  def perform(options = {})
    run_once = options.fetch(:run_once, false)

    ActiveRecord::Base.with_advisory_lock(:process_pending_emails,timeout_seconds: 1, shared: false) do
      ActiveRecord::Base.transaction do
        start_project_sent = Set.new
        reminder_project_sent = Set.new
        ended_project_sent = Set.new

        # Start all email sending jobs
        PendingStartEmail.complete.each do |email|
          send_project_emails(email, start_project_sent, :start)
        end

        # Send reminder emails
        PendingReminderEmail.complete.each do |email|
          send_project_emails(email, reminder_project_sent, :reminder)
        end

        # Send ended project emails
        PendingEndedEmail.complete.each do |email|
          send_project_emails(email, ended_project_sent, :ended)
        end

        # Now, update all groups
        current_datetime = DateTime.now

        Assignment.where(id: start_project_sent.to_a).update_all(sent_start_email: current_datetime)
        Assignment.where(id: reminder_project_sent.to_a).update_all(sent_reminder_email: current_datetime)
        Assignment.where(id: ended_project_sent.to_a).update_all(sent_ended_email: current_datetime)

        # And schedule our next run, unless this is the cron job
        if not run_once
          if (earliest = ProjectEvent.earliest)
            ProcessPendingEmailsJob.set(wait_until: earliest).perform_later
          end
        end
      end
    end
  end

  private
    def send_project_emails(email, assignment_set, email_method)
      # Add the group ids to the set
      assignment_set.merge(email.project.assignment_ids)
      # Schedule the mail delivery
      ProjectMailer.send(email_method, email.project, email.user).deliver_later
    end
end
