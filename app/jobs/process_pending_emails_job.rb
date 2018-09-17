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
      has_example_email = false

      "pending_#{queue}_email".camelize.constantize.complete.each do |email|
        # Only send one example.com email of each kind
        if email.user.email =~ /@example\.com$/
          if has_example_email
            next
          else
            has_example_email = true
          end
        end

        target = email.user.email
        if target =~ /@(example.com|world.com)$/
          # Redirect message to project owner if debugging
          target = email.project.owner.email
        else
          # Send to normal recipient
        end

        send_project_emails(email, assignment_set, queue, target)
      end

      unless assignment_set.empty?
        Assignment.where(id: assignment_set.to_a).update_all("sent_#{queue}_email" => current_datetime)
      end
    end

    def send_project_emails(email, assignment_set, email_method, target)
      # Add the group ids to the set
      assignment_set.merge(email.project.assignment_ids)
      # Schedule the mail delivery
      ProjectMailer.send(email_method, email.project, email.user, target).deliver_later
    end
end
