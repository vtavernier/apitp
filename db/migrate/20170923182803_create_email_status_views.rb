class CreateEmailStatusViews < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE VIEW pending_start_emails AS
        SELECT
          project_id,
          user_id
        FROM
          (SELECT
             assignments.project_id,
             users.id AS user_id,
             project_times.start_time    AS send_start,
             project_times.reminder_time AS send_end
           FROM assignments
             INNER JOIN group_memberships ON assignments.group_id = group_memberships.group_id
             INNER JOIN users ON group_memberships.user_id = users.id
             INNER JOIN project_times ON project_times.id = assignments.project_id
           GROUP BY assignments.project_id, users.id, send_start, send_end
           HAVING COUNT(sent_start_email) = 0) AS email_status
        WHERE send_start <= current_timestamp AND current_timestamp <= send_end;

      CREATE VIEW pending_reminder_emails AS
        SELECT
          project_id,
          user_id
        FROM
          (SELECT
             assignments.project_id,
             users.id AS user_id,
             project_times.reminder_time AS send_start,
             project_times.end_time      AS send_end
           FROM assignments
             INNER JOIN group_memberships ON assignments.group_id = group_memberships.group_id
             INNER JOIN users ON group_memberships.user_id = users.id
             INNER JOIN project_times ON project_times.id = assignments.project_id
             LEFT OUTER JOIN user_submissions
               ON user_submissions.user_id = users.id AND user_submissions.project_id = assignments.project_id
           GROUP BY assignments.project_id, users.id, send_start, send_end
           HAVING COUNT(sent_reminder_email) = 0 AND COUNT(submission_id) = 0) AS email_status
        WHERE send_start <= current_timestamp AND current_timestamp <= send_end;

      CREATE VIEW pending_ended_emails AS
        SELECT
          project_id,
          user_id
        FROM
          (SELECT
             assignments.project_id,
             users.id AS user_id,
             project_times.end_time                     AS send_start,
             project_times.end_time + INTERVAL '1 WEEK' AS send_end
           FROM assignments
             INNER JOIN group_memberships ON assignments.group_id = group_memberships.group_id
             INNER JOIN users ON group_memberships.user_id = users.id
             INNER JOIN project_times ON project_times.id = assignments.project_id
             LEFT OUTER JOIN user_submissions
               ON user_submissions.user_id = users.id AND user_submissions.project_id = assignments.project_id
           GROUP BY assignments.project_id, users.id, send_start, send_end
           HAVING COUNT(sent_ended_email) = 0 AND COUNT(submission_id) = 0) AS email_status
        WHERE send_start <= current_timestamp AND current_timestamp <= send_end;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW pending_start_emails;
      DROP VIEW pending_reminder_emails;
      DROP VIEW pending_ended_emails;
    SQL
  end
end
