class ProcessPendingEmailsJob < ApplicationJob
  queue_as :user_email

  def perform(options = {})
    ActiveRecord::Base.with_advisory_lock(:process_pending_emails, shared: false) do
      ActiveRecord::Base.transaction do
        current_datetime = DateTime.now

        # Send start emails
        process_email_queue(current_datetime,
                            :start)

        # Send reminder emails
        process_email_queue(current_datetime,
                            :reminder)

        # Send ended emails
        process_email_queue(current_datetime,
                            :ended)

        # Reschedule job if this is the scheduled instance
        interval = options[:reschedule_interval]
        if interval
          ProcessPendingEmailsJob
              .set(wait: ActiveSupport::Duration.parse(interval))
              .perform_later(options)
        end
      end
    end
  end

  private
    def process_email_queue(current_datetime, queue)
      assignment_set = Set.new

      "pending_#{queue}_email".camelize.constantize.complete.each do |email|
        send_project_emails(email, assignment_set, queue)
      end

      unless assignment_set.empty?
        Assignment.where(id: assignment_set.to_a).update_all("sent_#{queue}_email" => current_datetime)
      end
    end

    def send_project_emails(email, assignment_set, email_method)
      # Add the group ids to the set
      assignment_set.merge(email.project.assignment_ids)
      # Schedule the mail delivery
      ProjectMailer.send(email_method, email.project, email.user).deliver_later
    end
end
