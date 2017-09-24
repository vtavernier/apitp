class ImportJob < ApplicationJob
  queue_as :default

  def perform(file_path, admin_user_id, col_sep)
    created_users = []
    created_groups = []
    file_path = Rails.root.join(file_path)

    begin
      File.open(file_path, "rb:utf-8") do |f|
        ActiveRecord::Base.transaction do
          SmarterCSV.process(f, chunk_size: 10,
                             col_sep: col_sep) do |array|
            array.each do |row|
              params = ActionController::Parameters.new(row)
                           .require([:email, :name])

              # Update or create user
              user = User.find_or_initialize_by(email: params[0])
              if user.encrypted_password.blank?
                user.password = SecureRandom.base64(14)
                created_users << user
              end
              user.update(name: params[1])

              # Process groups
              current_year = SchoolDateHelper.school_year
              row.each do |k, group_name|
                next unless k.to_s.starts_with? 'group'
                group = Group.find_or_initialize_by(year: current_year,
                                                    name: group_name)
                if group.admin_user_id.nil?
                  group.admin_user_id = admin_user_id
                  created_groups << group
                end

                unless group.users.include? user
                  group.users << user
                end

                group.save
              end
            end
          end
        end
      end

      AdminMailer.import_succeeded(AdminUser.find(admin_user_id),
                                   File.basename(file_path),
                                   created_users,
                                   created_groups).deliver_now
    rescue StandardError => e
      AdminMailer.import_failed(AdminUser.find(admin_user_id),
                                File.basename(file_path),
                                e).deliver_now
    ensure
      FileUtils.rm_rf(File.dirname(file_path))
    end
  end
end
